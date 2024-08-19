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
  systemd.services."wireguard-wggrocy" = {
    bindsTo = ["netns@${name}.service"];
    after = ["netns@${name}.service"];
  };
  networking = {
    firewall = {
      allowedUDPPorts = [ config.networking.wireguard.interfaces."wg${name}".listenPort ];
    };
    wireguard.interfaces = {
      "wg${name}" = {
        privateKeyFile = config.age.secrets."wg${name}".path;
        socketNamespace = "init";
        interfaceNamespace = "${name}";
      };
    };
  };
  containers.${name} = {
    #privateNetwork = true;
    restartIfChanged = true;
    autoStart = true;
    #hostBridge = "brCont";
    specialArgs = {
      inherit inputs self;
    };
    extraFlags = [
      "--network-namespace-path=/run/netns/${name}"
    ];
  };
}
