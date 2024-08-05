{self, config, ...}:{
  imports = [
    ./containerDefault.nix
  ];
  age.secrets = {
    wggrocy = {
      rekeyFile = self + "/secrets/containers/grocy/wireguard.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };

  };
  systemd.network = {
    networks.wggrocy = {
      matchConfig.name = "wggrocy";
      address = [ "10.100.1.2/16" ];
      networkConfig = {
        IPForward = true;
      };
    };
    netdevs.wggrocy = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wggrocy";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wggrocy.path;
        ListenPort = 51821;
      };
    };
  };
  containers.grocy = {
    privateNetwork = true;
    restartIfChanged = true;
    autoStart = true;
    localAddress = "/16";
    hostBridge = "brCont";
    interfaces = [
      "wggrocy"
    ];
    bindMounts = {
      "/var/lib/grocy" = {
        hostPath = "/Storage/volumes/grocy";
        isReadOnly = false;
      };
    };
    config = {...}: {
      imports = [
        ./containerDefault.nix
      ];
      networking = {
      	firewall = {
	  allowedTCPPorts = [ 80 ];
	};
      };
      services.grocy = {
        enable = true;
        hostName = "grocy.faeranne.com";
        nginx.enableSSL = false;
        settings = {
          currency = "USD";
          culture = "en";
          calendar = {
            showWeekNumber = true;
            firstDayOfWeek = 0;
          };
        };
      };
    };
  };
}
