{self, config, lib, myLib, ...}:let
  meshWithoutMe = lib.remoteAttrs myLib.getAutomeshInstances [ config.networking.hostname ];
  peers = lib.mapAttrs (name: interface: let
    hostConfig = self.nixosConfigurations.${name}.config;
    pathSecret = myLib.getSecretFromPath hostConfig;
    secretName = pathSecret interface.privateKeyFile;
    rekey = hostConfig.age.secrets.${secretName}.rekeyFile;
    publicKeyFile = (lib.removeSuffix ".age" rekey + ".pub");
    endpoint = if hostConfig.topology.publicFQDN != null then (
      hostConfig.topology.publicFQDN + ":" + interface.listenPort
    ) else null;
  in {
    inherit endpoint;
    address = interface.ips[0];
    pubkey = builtins.readFile publicKeyFile;
  }) meshWithoutMe;
in {
  services.wgautomesh = {
    enable = true;
    enablePersistance = false;
    gossipSecretFile = "";
    settings = {
      inherit peers;
      interface = "wghub";
    };
  };
  age.secrets.automesh_gossip_secret = {
    rekeyFile = self + "/secrets/${config.networking.hostName}/automesh_gossip_secret.age";
    generator.script = "base64";
  };
}
