name: {self, inputs, config, ...}:{
  age.secrets = {
    "wg${name}" = {
      rekeyFile = self + "/secrets/containers/${name}/wireguard.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
  };
  /*
  systemd.network = {
    networks."wg${name}" = {
      matchConfig.name = "wg${name}";
      networkConfig = {
        IPForward = true;
      };
    };
    netdevs."wg${name}" = {
      enable = true;
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg${name}";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets."wg${name}".path;
      };
    };
  };
  */
  containers.${name} = {
    privateNetwork = true;
    restartIfChanged = true;
    autoStart = true;
    hostBridge = "brCont";
    specialArgs = {
      inherit inputs self;
    };
  };
}
