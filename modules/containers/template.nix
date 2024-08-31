name: {self, inputs, lib, config, ...}:{
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
      after = ["wireguard-wg${name}.service"];
    };
    "wireguard-wg${name}" = {
      bindsTo = ["netns@${name}.service"];
      after = ["netns@${name}.service" "netns@container.service"];
      before = [ "firewall.service" ];
    };
  };
  networking = {
    firewall.interfaces.wghub = {
      allowedUDPPorts = [ config.networking.wireguard.interfaces."wg${name}".listenPort ];
    };
    wireguard.interfaces = {
      "wggateway".peers = let
          wg = config.networking.wireguard.interfaces."wg${name}";
          wgPort = toString( wg.listenPort );
          publicKeyFile = (lib.removeSuffix ".age" config.age.secrets."wg${name}".rekeyFile + ".pub");
      in [ 
        {
          name = "${name}";
          endpoint = "127.0.0.1:${wgPort}";
          publicKey = builtins.readFile publicKeyFile;
          allowedIPs = wg.ips;
        } 
      ];
      "wg${name}" = {
        privateKeyFile = config.age.secrets."wg${name}".path;
        socketNamespace = "container";
        interfaceNamespace = "${name}";
        peers = let
          localGateway = config.networking.wireguard.interfaces.wggateway;
          gatewayPort = toString( localGateway.listenPort );
          publicKeyFile = (lib.removeSuffix ".age" config.age.secrets.wggateway.rekeyFile + ".pub");
        in [ 
          {
            name = "gateway";
            endpoint = "127.0.0.1:${gatewayPort}";
            publicKey = builtins.readFile publicKeyFile;
            allowedIPs = ["0.0.0.0/0"];
          } 
        ];
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
