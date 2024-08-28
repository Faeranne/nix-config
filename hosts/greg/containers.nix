{self, config, myLib, lib, ...}: let
  mkPeer = myLib.mkPeer "greg";
in {
  imports = [
    self.containerModules.jellyfin
    self.containerModules.servarr
    #self.containerModules.firefox-sync
    self.containerModules.rss
    self.containerModules.paperless
    self.containerModules.traefik
  ];
  networking = let
    traefikIp = lib.removeSuffix (builtins.elemAt config.networking.wireguard.interfaces.wghub.ips 0) "/32";
  in {
    nat = {
      forwardPorts = [
        {
          destination = "${traefikIp}:80";
          proto = "tcp";
          sourcePort = 80;
        }
        {
          destination = "${traefikIp}:443";
          proto = "tcp";
          sourcePort = 443;
        }
      ];
    };
    wireguard.interfaces = {
      "wgrss" = {
        listenPort = 51822;
        peers = [
          (mkPeer "traefik-greg")
        ];
      };
      "wgjellyfin" = {
        listenPort = 51823;
        peers = [
          (mkPeer "servarr")
          (mkPeer "traefik-greg")
        ];
      };
      "wgpaperless" = {
        listenPort = 51824;
        peers = [
          (mkPeer "traefik-greg")
        ];
      };
      "wgservarr" = {
        listenPort = 51825;
        peers = [
          (mkPeer "jellyfin")
          (mkPeer "traefik-greg")
        ];
      };
      "wgtraefik-greg" = {
        listenPort = 51826;
        peers = [
          (mkPeer "jellyfin")
          (mkPeer "rss")
          (mkPeer "paperless")
          (mkPeer "servarr")
        ];
      };
      /*
      "wgfirefox-sync" = {
        listenPort = 51826;
        peers = [
        ];
      };
      */
    };
  };
  containers = {
    traefik-greg = {
      bindMounts = {
        "/etc/traefik" = {
          hostPath = "/Storage/volumes/traefik";
        };
      };
      specialArgs = {
        hostName = "traefik.faeranne.com";
        toForward = [
          "jellyfin.jellyfin"
          "rss.rss"
          "paperless.paperless"
          "servarr.sonarr"
          "servarr.radarr"
          "servarr.lidarr"
          "servarr.prowlarr"
          "servarr.bazarr"
          "servarr.ombi"
        ];
        extraRouters = {
          wizarr = {
            rule = "Host(`wizarr.faeranne.com`)";
            service = "wizarr";
            entryPoints = [ "websecure" ];
          };
          actual = {
            rule = "Host(`actual.faeranne.com`)";
            service = "actual";
            entryPoints = [ "websecure" ];
          };
        };
        extraServices = {
          wizarr.loadBalancer.servers = [ {url = "http://10.88.1.3:5690"; } ];
          actual.loadBalancer.servers = [ {url = "http://10.88.1.4:5006"; } ];
        };
      };
    };
    jellyfin = {
      bindMounts = {
        "/media" = {
          hostPath = "/Storage/media";
        };
        "/var/lib/jellyfin" = {
          hostPath = "/Storage/volumes/jellyfin";
        };
        "/config" = {
          hostPath = "/Storage/volumes/jellyfin";
        };
      };
      specialArgs = {
        hostName = "jellyfin.faeranne.com";
      };
    };
    rss = {
      bindMounts = {
        "/var/lib/freshrss" = {
          hostPath = "/Storage/volumes/freshrss";
        };
      };
      specialArgs = {
        hostName = "rss.faeranne.com";
      };
    };
    /*
    firefox-sync = {
      bindMounts = {
        "/var/lib/mysql" = { #Prefer not including host path here, save it for the host itself
          hostPath = "/Storage/volumes/foxsync/sql";
        };
      };
      specialArgs = {
        hostName = "foxsync.faeranne.com";
      };
    };
    */
    paperless = {
      bindMounts = {
        "/var/lib/paperless" = { #Prefer not including host path here, save it for the host itself
          hostPath = "/Storage/volumes/paperless";
        };
        "/var/lib/paperless/media" = { #Prefer not including host path here, save it for the host itself
          hostPath = "/Storage/media/paperless";
        };
      };
      specialArgs = {
        hostName = "paperless.faeranne.com";
        trustedProxy = "10.200.1.8";
      };
    };
    servarr = {
      bindMounts = {
        "/var/lib/sonarr" = {
          hostPath = "/Storage/volumes/sonarr";
        };
        "/var/lib/radarr" = {
          hostPath = "/Storage/volumes/radarr";
        };
        "/var/lib/lidarr" = {
          hostPath = "/Storage/volumes/lidarr";
        };
        "/var/lib/private/prowlarr" = {
          hostPath = "/Storage/volumes/prowlarr";
        };
        "/var/lib/ombi" = {
          hostPath = "/Storage/volumes/ombi";
        };
        "/var/lib/bazarr" = {
          hostPath = "/Storage/volumes/bazarr";
        };
        "/transmission" = {
          hostPath = "/Storage/volumes/transmission";
        };
        "/tv" = {
          hostPath = "/Storage/media/tv";
        };
        "/movies" = {
          hostPath = "/Storage/media/movies";
        };
        "/music" = {
          hostPath = "/Storage/media/music";
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
      };
    };
  };
}
