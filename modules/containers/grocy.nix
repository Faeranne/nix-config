addConfig: {...}:{
  imports = [
    (import ./template.nix "grocy")
  ];
  /*
  systemd.network = {
    networks.wggrocy = {
      address = [ "10.100.1.2/16" ];
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
  containers.grocy = {
    bindMounts = {
      "/var/lib/grocy" = {
        isReadOnly = false;
      };
    };
    config = {...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ 80 ];
        };
      };
      services.grocy = {
        inherit (addConfig) hostName;
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
