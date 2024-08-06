{self, config, ...}:{
  imports = [
    (import ./containerBase.nix "grocy")
  ];
  systemd.network = {
    networks.wggrocy = {
      address = [ "10.100.1.2/16" ];
    };
    netdevs.wggrocy = {
      wireguardConfig = {
        ListenPort = 51821;
      };
    };
  };
  containers.grocy = {
    localAddress = "/16";
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
