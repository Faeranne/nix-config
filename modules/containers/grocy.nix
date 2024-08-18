{config, ...}:{
  imports = [
    (import ./template.nix "grocy")
  ];
  networking = {
    wireguard.interfaces = {
      "wggrocy" = {
        ips = ["10.100.1.3/32"];
        listenPort = 51821;
      };
    };
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
