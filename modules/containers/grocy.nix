{config, ...}:{
  imports = [
    (import ./template.nix "grocy")
  ];
  /*
  systemd.network = {
    networks.wggrocy = {
      address = "10.100.1.2/16";
    };
    netdevs.wggrocy = {
      wireguardConfig = {
        ListenPort = 51821;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            AllowedIPs = [
              "10.100.1.1/32"
            ];
            Endpoint = "127.0.0.1:51820";
            PersistentKeepalive = 15;
            PublicKey = builtins.readFile (self + "/secrets/containers/sarah/wireguard.pub");
          };
        }
      ];
    };
  };
  */
  networking.wireguard.interfaces = {
    wggrocy = {
      ips = ["10.100.1.2/32"];
      privateKeyFile = config.age.secrets.wggrocy.path;
      socketNamespace = "init";
      interfaceNamespace = "grocy";
      peers = [];
    };
  };
  systemd.services."wireguard-wggrocy" = {
    bindsTo = ["netns@grocy.service"];
    after = ["netns@grocy.service"];
  };
  containers.grocy = {
    bindMounts = {
      "/var/lib/grocy" = {
        isReadOnly = false;
      };
    };
    config = {config, hostName, ...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ 80 ];
        };
      };
      topology.self = {
        interfaces.enp10s0 = {
          addresses = ["192.168.1.80"];
          network = "home";
          physicalConnections = [
            (config.lib.topology.mkConnection "switch2" "eth2")
          ];
        };
      };

      services.grocy = {
        inherit hostName;
        enable = true;
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
