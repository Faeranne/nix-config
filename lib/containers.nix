(super: prev: let
  lib = super.inputs.nixpkgs.lib;
in {
  getContainerFullName = host: name: "${host}-${name}";
  getContainerName = name: (let
    res = builtins.match "(.*)-(.*)" name;
  in
    builtins.elemAt res 1
  );
  getContainerHost = name: (let
    res = builtins.match "(.*)-(.*)" name;
  in
    builtins.elemAt res 0
  );
  allContainersForHost = hostname: (if (builtins.pathExists ../hosts/${hostname}/containers) then (let
    files = super.getFiles ../hosts/${hostname}/containers;
  in
    map (x: super.splitFileName x) files
  ) else []);

  allContainerConfigs = (let
    hosts = super.allHosts;
  in
    lib.foldl (acc: host: (let
      configs = super.getContainerConfigsForHost host;
      containerNames = builtins.attrNames configs;
    in
      lib.foldl (acc2: container: {
        ${super.getContainerFullName host container} = configs.${container};
      } // acc2) {} containerNames
    ) // acc) {} hosts
  );

  getContainer = fullName: (let
    host = super.getContainerHost fullName;
    name = super.getContainerName fullName;
  in
    import ../hosts/${host}/containers/${name}.nix
  );

  getContainerOrder = host:
    if (
      builtins.pathExists ../hosts/${host}/containers.json
    ) then ( 
      builtins.fromJSON (builtins.readFile ../hosts/${host}/containers.json)
    ) else [];

  #TODO: This builds static containers per host, but I'd like to build the containers to live anywhere instead.
  getContainerConfigsForHost = host: (let
    order = super.getContainerOrder host;
    hostConfig = super.getHostConfig host;
    containerList = super.allContainersForHost host;
    checkContainers = (
      (builtins.toJSON 
        (builtins.sort (a: b: a < b) containerList)
      ) == (builtins.toJSON 
        (builtins.sort (a: b: a < b) order)
      )
    ) || (
      builtins.abort "hosts/${host}/containers.json does not contain exactly all containers from hosts/${host}/containers/.  Run `nix run .#updateContainers` to correct the list."
    );

    configs = lib.foldl (acc: container: let
      nextId = acc.currentId + 1;
      containerConfig = super.getContainer (super.getContainerFullName host container);
      containerIpEnd = acc.currentId+2;
      containerIp = "${if containerConfig.network.isolate then super.baseIsolationIp else super.baseContainerIp}.${toString containerIpEnd}";
      containerWgIp = "${super.wireguardBaseIp}.${toString hostConfig.id}.${toString containerIpEnd}";
      containerWgPort = containerIpEnd+35600;
    in
      acc // {
        ${container} = containerConfig // {
          inherit host;
          name = container;
          wireguardPort = containerWgPort;
          wireguardIp = containerWgIp;
          ip = containerIp;
          id = acc.currentId;
          ipEnd = containerIpEnd;
        };
        currentId = nextId;
      }
    ) {currentId = 0;} order;
  in
    if checkContainers then (builtins.removeAttrs configs ["currentId"]) else {}
  );
})
