{...}:let
  containerName = "servarr";
in {
  imports = [
    (import ./template.nix containerName)
  ];
  networking = {
    wireguard.interfaces = {
      "wg${containerName}" = {
        ips = ["10.100.1.6/32"];
      };
    };
  };



  containers.${containerName} = {
    bindMounts = {
      "/var/lib/sonarr" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/radarr" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/lidarr" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/private/prowlarr" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/ombi" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/bazarr" = {
        isReadOnly = false;
        create = true;
      };
      "/transmission" = {
        isReadOnly = false;
        create = true;
      };
      "/tv" = {
        isReadOnly = false;
        create = true;
      };
      "/movies" = {
        isReadOnly = false;
        create = true;
      };
      "/music" = {
        isReadOnly = false;
        create = true;
      };
    };

    specialArgs = {
      ports = {
        sonarr = 8989;
        radarr = 7878;
        lidarr = 8686;
        prowlarr = 9696;
        bazarr = 6767;
        ombi = 5000;
      };
    };
    config = {ports, lib, ...}: let
      portList = lib.mapAttrsToList (service: port: port) ports;
    in {
      imports = [
        ./base.nix
      ];

      networking = {
        firewall = {
          allowedTCPPorts = portList;
        };
      };

      services = {
        prowlarr.enable = true; 
        sonarr = {
          enable = true;
          dataDir = "/var/lib/sonarr";
          group = "users";
        };
        radarr = {
          enable = true;
          dataDir = "/var/lib/radarr";
          group = "users";
        };
        lidarr = {
          enable = true;
          dataDir = "/var/lib/lidarr";
          group = "users";
        };
        bazarr = {
          enable = true;
          group = "users";
        };
        ombi = {
          enable = true;
          group = "users";
        };
      };

    };
  };
}
