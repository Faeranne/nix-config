{self, myLib, pkgs, ...}:let
  containerName = "servarr";
  inherit (myLib) getWireguardHost;
  myHost = self.topology.${pkgs.system}.config.nodes.${containerName}.parent;
  mkPeer = myLib.mkPeer myHost;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking = {
    wireguard.interfaces = {
      "wg${containerName}" = {
        ips = ["10.100.1.6/32"];
        listenPort = 51824;
        peers = [
          (mkPeer "jellyfin")
          (mkPeer "greg")
        ];
      };
    };
  };



  containers.${containerName} = {
    bindMounts = {
      "/var/lib/sonarr" = {
        isReadOnly = false;
      };
      "/var/lib/radarr" = {
        isReadOnly = false;
      };
      "/var/lib/lidarr" = {
        isReadOnly = false;
      };
      "/var/lib/private/prowlarr" = {
        isReadOnly = false;
      };
      "/var/lib/ombi" = {
        isReadOnly = false;
      };
      "/var/lib/bazarr" = {
        isReadOnly = false;
      };
      "/transmission" = {
        isReadOnly = false;
      };
      "/tv" = {
        isReadOnly = false;
      };
      "/movies" = {
        isReadOnly = false;
      };
      "/music" = {
        isReadOnly = false;
      };
    };

    specialArgs = {
      hostNames = {
        sonarr = "sonarr.faeranne.com";
        radarr = "radarr.faeranne.com";
        lidarr = "lidarr.faeranne.com";
        prowlarr = "prowlarr.faeranne.com";
        bazarr = "bazarr.faeranne.com";
        ombi = "request.faeranne.com";
      };
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
