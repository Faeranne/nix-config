{config, ...}:let
  containerName = "servarr";
in {
  imports = [
    (import ./template.nix containerName)
  ];
  networking = { wireguard.interfaces = {
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
        owner = "container:users";
      };
      "/var/lib/radarr" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/var/lib/lidarr" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/var/lib/private/prowlarr" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/var/lib/ombi" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/var/lib/bazarr" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/transmission" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/tv" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/movies" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
      };
      "/music" = {
        isReadOnly = false;
        create = true;
        owner = "container:users";
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
      hostConfig = config;
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
          user = "container";
          group = "users";
        };
        radarr = {
          enable = true;
          dataDir = "/var/lib/radarr";
          user = "container";
          group = "users";
        };
        lidarr = {
          enable = true;
          dataDir = "/var/lib/lidarr";
          user = "container";
          group = "users";
        };
        bazarr = {
          enable = true;
          user = "container";
          group = "users";
        };
        ombi = {
          enable = true;
          user = "container";
          group = "users";
        };
      };
      users = {
        users.container = {
          isSystemUser = true;
          group = "container";
          uid = hostConfig.users.users.container.uid;
        };
        groups = {
          container = {
            gid = hostConfig.users.groups.container.gid;
          };
        };
      };
    };
  };
}
