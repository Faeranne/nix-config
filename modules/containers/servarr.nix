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

    config = {config, ...}: {
      imports = [
        ./base.nix
      ];

      networking = {
        firewall = {
          allowedTCPPorts = [ 9696 8989 7878 8686 config.services.bazarr.listenPort config.services.ombi.port ];
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
