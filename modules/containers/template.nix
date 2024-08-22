name: {self, inputs, myLib, config, ...}:{
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
  systemd.services = {
    "container@${name}" = {
      after = ["wireguard-wg${name}"];
    };
    "wireguard-wg${name}" = {
      bindsTo = ["netns@${name}.service"];
      after = ["netns@${name}.service" "netns@container.service"];
    };
  };
  networking = {
    firewall.interfaces.wghub = {
      allowedUDPPorts = [ config.networking.wireguard.interfaces."wg${name}".listenPort ];
    };
    wireguard.interfaces = {
      "wg${name}" = {
        privateKeyFile = config.age.secrets."wg${name}".path;
        socketNamespace = "container";
        interfaceNamespace = "${name}";
        peers = [ (myLib.mkGateway config.networking.hostName) ];
      };
    };
  };
  containers.${name} = {
    restartIfChanged = true;
    autoStart = true;
    specialArgs = {
      inherit inputs self;
    };
    extraFlags = [
      "--network-namespace-path=/run/netns/${name}"
    ];
  };
}
