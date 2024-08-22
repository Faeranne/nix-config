inputs: system: let
  inherit (inputs) self;
  inherit (inputs.nixpkgs.lib) removeSuffix mapAttrs concatMapAttrs genAttrs;
  getWireguardHost = (wireName: let
    hosts = builtins.attrNames self.nixosConfigurations;
    host = builtins.foldl' (acc: name: 
      if (builtins.hasAttr "wg${wireName}" self.nixosConfigurations.${name}.config.networking.wireguard.interfaces) then name else acc
    ) "" hosts;
  in host);
  mkPeer = (local: goal: let
    remote = getWireguardHost goal;
    remoteConfig = self.nixosConfigurations.${remote}.config;
    remoteIp = removeSuffix (toString (builtins.elemAt remoteConfig.networking.wireguard.interfaces.wghub.ips 0)) "/32";
    goalWireguard = remoteConfig.networking.wireguard.interfaces."wg${goal}";
    publicKeyFile = (removeSuffix ".age" remoteConfig.age.secrets."wg${goal}".rekeyFile + ".pub");
  in {
    name = goal;
    endpoint = "${toString remoteIp}:${toString goalWireguard.listenPort}";
    publicKey = builtins.readFile publicKeyFile;
    allowedIPs = goalWireguard.ips;
  });
  mkGateway = (local: let
    peer = mkPeer local local;
  in peer // {
    allowedIPs = ["0.0.0.0/0"];
  });
  gatherContainers = (
    concatMapAttrs (host: hostInstance: let
      hostConfig = hostInstance.config;
      hostWireguards = hostConfig.networking.wireguard.interfaces;
    in mapAttrs (container: containerInstance:
      let
        specialArgs = containerInstance.specialArgs;
        wg = hostWireguards."wg${container}";
        ports = if (builtins.hasAttrs "ports" specialArgs) then
          specialArgs.ports
        else
          {${container} = specialArgs.port;};
        hostNames = if (builtins.hasAttrs "hostNames" specialArgs) then
          specialArgs.hostNames
        else
          {${container} = specialArgs.hostName;};
        serviceNames = builtins.attrNames hostNames;
      in {
        inherit host;
        ip = (removeSuffix "/32" (builtins.elemAt wg.ips 0));
        port = wg.listenPort;
        publicKeyFile = (removeSuffix ".age" wg.rekeyFile + ".pub");
        services = genAttrs serviceNames (service: {
          ${service} = {
            hostName = hostNames.${service};
            port = ports.${service};
          };
        });
      }) hostConfig.containers
    ) self.nixosConfigurations
  );
in {
  inherit mkPeer getWireguardHost mkGateway gatherContainers;
}
