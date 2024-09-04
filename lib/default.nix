inputs: let
  inherit (inputs) self;
  inherit (inputs.nixpkgs.lib) assertMsg removePrefix removeSuffix mapAttrs concatMapAttrs genAttrs foldlAttrs;
  /**
    Returns the canonical host of a given wireguard endpoint. Assumes all endpoints are unique across all hosts

    # Example

    ```nix
    getWireguardHost "jellyfin"
    =>
    "greg"
    ```


    # Type

    ```
    getWireguardHost :: String -> String
    ```


    # Arguments

    wireName
    : The wireguard key as a string

  */
  getWireguardHost = (wireName: let
    host = foldlAttrs (acc: name: value: 
      if (builtins.hasAttr "wg${wireName}" value.config.networking.wireguard.interfaces) then name else acc
    ) "" self.nixosConfigurations;
  in assert assertMsg (host != "") "Could not find wg${wireName} in any host"; host);
  /**
    Creates a valid peer submodule config from two wireguard key strings.  Assumes all wireguard enpoints are unique across all hosts

    # Example

    ```nix
    mkPeer "jellyfin" "traefikgreg"
    =>
    {
      name = "traefikgreg";
      endpoint = "10.110.1.2:51826";
      publicKey = "afETzsN69oIqLCQLhfESwgv2PBVIYzqBsQTDHh8j/C0=";
      allowedIPs = [ "10.100.2.1/32" ];
    }
    ```


    # Type

    ```
    mkPeer :: String -> String -> Submodule
    ```


    # Arguments

    local
    : The key name of the wireguard endpoint this peer is being added to

    goal
    : The key name of the target wireguard endpoint being connected to

  */
  mkPeer = (local: goal: let
    remote = getWireguardHost goal;
    remoteConfig = self.nixosConfigurations.${remote}.config;
    remoteIp = removeSuffix "/32" (toString (builtins.elemAt remoteConfig.networking.wireguard.interfaces.wghub.ips 0));
    goalWireguard = remoteConfig.networking.wireguard.interfaces."wg${goal}";
    publicKeyFile = (removeSuffix ".age" remoteConfig.age.secrets."wg${goal}".rekeyFile + ".pub");
  in {
    name = goal;
    endpoint = "${toString remoteIp}:${toString goalWireguard.listenPort}";
    publicKey = builtins.readFile publicKeyFile;
    allowedIPs = goalWireguard.ips;
  });
  /**
    This gathers every container in the entire config.  This is not a function
    and does not accept any arguments.  Currently doesn't ignore containers without
    wireguard nets, so will break if you add a container that doesn't have networking


    # Example

    ```nix
    gatherContainers
    =>
    {
      git = {
        host = "greg";
        ip = "10.100.1.10";
        port = 51827;
        publicKeyFile = "/nix/store/.../wireguard.pub";
        services = {
          # Services are either presented by the container config in ports and hostNames,
          # or assumed to be just the one service with the same name as the container
          git = {
            hostName = "git.faeranne.com";
            port = 8000;
          };
        };
      };
      ...
    }
    ```
  */
  gatherContainers = (
    concatMapAttrs (host: hostInstance: let
      hostConfig = hostInstance.config;
      hostWireguards = hostConfig.networking.wireguard.interfaces;
      pathSecret = getSecretFromPath hostConfig;
    in mapAttrs (container: containerInstance:
      let
        specialArgs = containerInstance.specialArgs;
        wg = hostWireguards."wg${container}";
        ports = if (builtins.hasAttr "ports" specialArgs) then
          specialArgs.ports
        else
          {${container} = specialArgs.port;};
        hostNames = if (builtins.hasAttr "hostNames" specialArgs) then
          specialArgs.hostNames
        else
          {${container} = specialArgs.hostName;};
        serviceNames = builtins.attrNames hostNames;
        secretName = pathSecret wg.privateKeyFile;
        rekey = hostConfig.age.secrets.${secretName}.rekeyFile;
      in {
        inherit host;
        ip = (removeSuffix "/32" (builtins.elemAt wg.ips 0));
        port = wg.listenPort;
        publicKeyFile = (removeSuffix ".age" rekey + ".pub");
        services = genAttrs serviceNames (service: {
          hostName = hostNames.${service};
          port = ports.${service};
        });
      }) hostConfig.containers
    ) self.nixosConfigurations
  );
  getAutomeshInterfaces = (
    concatMapAttrs (host: hostInstance: let
    interfaceName = hostInstance.services.wgautomesh.settings.interface;
    in if interfaceName != null then {
      host = hostInstance.networking.wireguard.interfaces.${interfaceName};
    } else {}) self.nixosConfigurations
  );
  getSecretFromPath = (config: path: let
    agePath = config.age.secretsDir + "/";
    secretName = removePrefix agePath path;
  in secretName);
in {
  inherit mkPeer getWireguardHost gatherContainers getAutomeshInterfaces getSecretFromPath;
}
