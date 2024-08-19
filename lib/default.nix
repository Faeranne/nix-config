inputs: system: let
  inherit (inputs) self;
  inherit (inputs.nixpkgs.lib) removeSuffix;
  config = self.topology.${system}.config;
  getWireguardHost = (wireName: let
    hosts = builtins.attrNames self.nixosConfigurations;
    host = builtins.foldl' (acc: name: 
      if (builtins.hasAttr "wg${wireName}" self.nixosConfigurations.${name}.config.networking.wireguard.interfaces) then name else acc
    ) "" hosts;
  in host);
  mkPeer = (local: goal: let
    remote = getWireguardHost goal;
    remoteConfig = self.nixosConfigurations.${remote}.config;
    goalWireguard = remoteConfig.networking.wireguard.interfaces."wg${goal}";
    publicKeyFile = (removeSuffix ".age" remoteConfig.age.secrets."wg${goal}".rekeyFile + ".pub");
  in {
    name = goal;
    endpoint = "${toString (pairedIP remote local)}:${toString goalWireguard.listenPort}";
    publicKey = builtins.readFile publicKeyFile;
    allowedIPs = goalWireguard.ips;
  });
  mkGateway = (local: goal: let
    remote = getWireguardHost goal;
    remoteConfig = self.nixosConfigurations.${remote}.config;
    goalWireguard = remoteConfig.networking.wireguard.interfaces."wg${goal}";
    publicKeyFile = (removeSuffix ".age" remoteConfig.age.secrets."wg${goal}".rekeyFile + ".pub");
  in {
    name = goal;
    endpoint = "${toString (pairedIP remote local)}:${toString goalWireguard.listenPort}";
    publicKey = builtins.readFile publicKeyFile;
    allowedIPs = ["0.0.0.0/0"];
  });
  pairedIP = (target: source: let
    sourceNetwork = config.nodes.${source}.primaryNetwork;
    targetNetwork = config.nodes.${target}.primaryNetwork;
    router = config.networks.${targetNetwork}.router.name;
    ip = if targetNetwork == sourceNetwork then (nodeIP target) else (pairedIP router source);
  in ip);
  nodeIP = (target: let
    interface = config.nodes.${target}.primaryInterface;
    ip = builtins.elemAt config.nodes.${target}.interfaces.${interface}.addresses 0;
  in ip);
in {
  inherit mkPeer pairedIP nodeIP getWireguardHost;
}
