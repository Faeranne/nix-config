inputs: let
  inherit (inputs) self;
  inherit (inputs.nixpkgs.lib) assertMsg removePrefix removeSuffix mapAttrs concatMapAttrs genAttrs foldlAttrs;
  getWireguardHost = (wireName: let
    host = foldlAttrs (acc: name: value: 
      if (builtins.hasAttr "wg${wireName}" value.config.networking.wireguard.interfaces) then name else acc
    ) "" self.nixosConfigurations;
  in assert assertMsg (host != "") "Could not find wg${wireName} in any host"; host);
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
  gatherContainers = (
    concatMapAttrs (host: hostInstance: let
      hostConfig = hostInstance.config;
      hostWireguards = hostConfig.networking.wireguard.interfaces;
      agePath = hostConfig.age.secretsDir + "/";
    in mapAttrs (container: containerInstance:
      let
        specialArgs = containerInstance.specialArgs;
        wg = hostWireguards."wg${container}";
        ports = if (builtins.hasAttr "ports" (builtins.trace specialArgs specialArgs)) then
          specialArgs.ports
        else
          {${container} = specialArgs.port;};
        hostNames = if (builtins.hasAttr "hostNames" specialArgs) then
          specialArgs.hostNames
        else
          {${container} = specialArgs.hostName;};
        serviceNames = builtins.attrNames hostNames;
        secretName = removePrefix agePath wg.privateKeyFile;
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
in {
  inherit mkPeer getWireguardHost gatherContainers;
}
