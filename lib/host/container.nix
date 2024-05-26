inputs: let
  utils = ../utils.nix;
in {
  getContainerFullName = host: name: "${host}-${name}";

  #Break the canonical container name into the container's name.
  getContainerName = name: (let
    res = builtins.match "(.*)-(.*)" name;
  in
    builtins.elemAt res 1
  );

  #Break the canonical container name into the host's name.
  getContainerHost = name: (let
    res = builtins.match "(.*)-(.*)" name;
  in
    builtins.elemAt res 0
  );

  #Get every container defined for a host.  This is used for verifying the 
  #`containers.json` file.
  allContainersForHost = hostname: (if (builtins.pathExists ../../hosts/${hostname}/containers) then (let
    files = utils.getFiles ../../hosts/${hostname}/containers;
  in
    map (x: utils.splitFileName x) files
  ) else []);

  #Get every container config as a "canonical container name" -> config pairing
  #This gets passed to each host to allow hosts and containers to reference
  #container ips and other such details.
  allContainerConfigs = (let
    hosts = utils.allHosts;
  in
    builtins.foldl' (acc: host: (let
      configs = getContainerConfigsForHost host;
      containerNames = builtins.attrNames configs;
    in
      builtins.foldl' (acc2: container: {
        ${getContainerFullName host container} = configs.${container};
      } // acc2) {} containerNames
    ) // acc) {} hosts
  );

  
  #Get the container config data based on a canonical container name.
  getContainer = fullName: (let
    host = getContainerHost fullName;
    name = getContainerName fullName;
  in
    import ../../hosts/${host}/containers/${name}.nix
  );
  
  #Get the expected order of containers from `containers.json`.
  #This is ultimatly used to define containers and derive
  #their ID value, so it's important that it exists and contains
  #exactly the containers in `contianers/` for a host. otherwise
  #we can end up with a container without an id, or a container
  #without a config.
  getContainerOrder = host:
    if (
      builtins.pathExists ../../hosts/${host}/containers.json
    ) then ( 
      builtins.fromJSON (builtins.readFile ../../hosts/${host}/containers.json)
    ) else [];

  #Returns every possible container config for a given host,
  #based on `containers.json`
  getContainerConfigsForHost = host: (let
    order = getContainerOrder host;
    hostConfig = utils.getHostConfig host;
    containerList = allContainersForHost host;
    #this ensures the container in `containers/` matches the
    #list in `containers.json`, so that we aren't caught off
    #guard when a container is added or removed.
    #TODO: eventually this should also yell if the number of
    #containers is over 253, since that will break the ip
    #space.  Unlikely to ever happen, but something to be 
    #aware of.
    checkContainers = (
      (toJSON 
        (sort (a: b: a < b) containerList)
      ) == (toJSON 
        (sort (a: b: a < b) order)
      )
    ) || (
      builtins.abort "hosts/${host}/containers.json does not contain exactly all containers from hosts/${host}/containers/.  Run `nix run .#updateContainers` to correct the list."
    );
    #Container ID time.  This handles assigning the ids based
    #on the container's order in `containers.json`, as well as
    #defining things like the wireguardip, the port wireguard 
    #will end up listening on, and so on.  This ensures that
    #container ip addresses remain consistant when the actual
    #container lists change, since otherwise it would generate
    #ids in alphabetical order, which may change a container's
    #ip address.
    configs = foldl' (acc: container: let
      #`currentId` handles the id index, since there is no
      #index value passed from `foldl'`.
      nextId = acc.currentId + 1;
      containerConfig = getContainer (getContainerFullName host container);
      #We bump the Ip address up 2 since ids start at 0, and 1 is occupied by
      #the host.
      containerIpEnd = acc.currentId+2;
      containerIp = "${baseContainerIp}.${toString containerIpEnd}";
      containerWgIp = "${wireguardBaseIp}.${toString hostConfig.id}.${toString containerIpEnd}";
      containerWgPort = containerIpEnd+35600;
    in
      acc // {
        ${container} = containerConfig // {inherit host; name = container; wireguardPort = containerWgPort; wireguardIp = containerWgIp; ip = containerIp; id = acc.currentId;};
        #When passing forward, we update `currentId`.
        currentId = nextId;
      }
      #Gotta define currentId as 0 to start off with.
    ) {currentId = 0;} order;
  in
    #We do the actual check here, then remember to remove `currentId` from the set.
    #since all evaluation is lazy, we don't have to worry about the above evaluating first if
    #the check fails.
    if checkContainers then (removeAttrs configs ["currentId"]) else {}
  );
  generateContainer = containerConfig: let

    /*
      tcpPorts and udpPorts are intended to container an array of the ports referenced in the containers config file.
      This is done by looping through the `network.ports` set via `foldl'`ing the names of the ports,
      and checking if `type` is either "tcp" or "udp" respectively.  If so, we add the port number to an array and
      adding that to the existing list of ports for that type.
    */
    portNames = builtins.attrNames containerConfig.network.ports;
    tcpPorts = builtins.foldl' (acc: portName: let
      isTcp = containerConfig.network.ports.${portName}.type == "tcp";
    in
      (if isTcp then [ containerConfig.network.ports.${portName}.port ] else []) ++ acc
    ) [] portNames;
    udpPorts = builtins.foldl' (acc: portName: let
      isUdp = containerConfig.network.ports.${portName}.type == "udp";
    in
      (if isUdp then [ containerConfig.network.ports.${portName}.port ] else []) ++ acc
    ) [] portNames;

  in {config, systemConfig, ...}:let
    /*
      Secret paths are based on the system config's `age.secrets` set, so we gotta do this *inside* the nixos
      module space.  We first make sure the container config contains a `secrets` array. if it does, we can
      just `foldl'` through it and set `/run/secrets` mounts to the output path of each secret.  Since secrets
      are files generated from the nix store (not actual derivations, but they are derived via a systemd service)
      we don't want the container to accidentally try and edit them.  As such we mark these folders explicitly as
      `isReadOnly` to make them read-only.
    */
    secretMounts = if (builtins.hasAttr "secrets" containerConfig) then (builtins.foldl' (acc: secret: {
      "/run/secrets/${secret}" = {
        hostPath = "${config.age.secrets."${secret}".path}";
        isReadOnly = true;
      };
    }//acc) {} containerConfig.secrets) else {};
    # We already have existing bindMounts from the container config, so we merge them here with secretMounts.
    bindMounts = containerConfig.bindMounts // secretMounts;
  in {
    age.secrets."wg${containerConfig.name}" = {
      rekeyFile = ../hosts/${systemConfig.hostname}/secrets/wireguard-${containerConfig.name}.age;
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
    systemd.network.netdevs."wg${containerConfig.name}" = {
      enable = true;
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets."wg${containerConfig.name}".path;
        ListenPort = 51821+containerConfig.id;
      };
    };
    containers = {
      ${containerConfig.name} = {
        /*
          Normally I would just inherit `tmpfs`, but since it isn't always set, we gotta check for it's existince
          first, then set the `tmpfs` value to it *only* if it exists. if it doesn't, we still gotta set it, so we
          set it as an empty list.
        */
        tmpfs = if (builtins.hasAttr "tmpfs" containerConfig) then containerConfig.tmpfs else [];
        inherit bindMounts;
        autoStart = true;
        privateNetwork = true;
        restartIfChanged = true;
        /*
          The localIP of containers is now generated from the containerConfig.id value, which in-turn is generated 
          from the order in `containers.json`.  We do this to make adding new containers simpler via an `updateContainers`
          command in the nix file, vs needing to keep track of ids.  This also ensures a container's ip is static
          so long as it still exists. For a given server this is mostly irrelivant, but since wireguard ip's are
          also configured in this way, we gotta keep them consistant to prevent needing constant re-deployment on
          other servers when a new container is added and causes the container list to sort differently.
        */
        localAddress = "${containerConfig.ip}/16";
        #Host bridge is always `brCont` due to being set in `modules/nixos/containers.nix`, so we just static it here.
        hostBridge = "brCont";
        specialArgs = {
          inherit containerConfig;
        };
        config = {config, lib, pkgs, ...}: {
          imports = [
            containerConfig.config
          ];
          /*
            These are some default configs needed to make nat routing work right. Apparently default nixos
            setup causes it to copy the host's `resolv.conf` file, which doesn't work in private namespaces.
            So we forcibly disable that, and set our defaultGateway and enable local resolved.
            While we're at it, we also set our tcp and udp ports for the firewall.  This allows access to the
            other containers and WireGuard network.
            see more here: https://nixos.wiki/wiki/NixOS_Containers
            and the original bug is tracked here: https://github.com/NixOS/nixpkgs/issues/162686
          */
          networking = {
            useHostResolvConf = lib.mkForce false;
            defaultGateway = "10.200.0.1";
            firewall.allowedTCPPorts = tcpPorts;
            firewall.allowedUDPPorts = tcpPorts;
          };
          services.resolved.enable = true;
          /*
            Right now everything is set to 23.11 since that is the current stable version as of this config being
            made.  Note that this should *not* be changed unless you are working from scratch.  The jist is that
            this defines non-nix config file formats and some other version-to-version stuff that doesn't forward
            port. For example, Postgres doesn't support simply updating the postgres version to the latest major
            version. You have to export and re-import the dataset for each major version.  Since there is no
            idempotent way to do this, NixOS just locks these things down.  As such, changing this will break
            *many things* unless you do a manual update on the things that need it, or are working from a completely
            stock setup.  There's no real harm in keeping it at 23.11 unless you're specifically trying to update
            things like Postgres, so we just keep it static here.
            Touch this at your own peril!
          */
          system.stateVersion = "23.11";
        };
      };
    };
  };
}
