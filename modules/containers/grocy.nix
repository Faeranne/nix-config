{...}:{
  imports = [
    (import ./template.nix "grocy")
  ];
  networking = {
    wireguard.interfaces = {
      "wggrocy" = {
        ips = ["10.100.1.3/32"];
      };
    };
  };
  containers.grocy = {
    bindMounts = {
      "/var/lib/grocy" = {
        isReadOnly = false;
        create = true;
      };
    };
    config = {hostName, ...}: {
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
