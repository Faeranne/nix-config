{self, myLib, ...}: let
  mkPeer = myLib.mkPeer "greg";
in {
  imports = [
    self.containerModules.jellyfin
    self.containerModules.servarr
    self.containerModules.firefox-sync
    self.containerModules.rss
    self.containerModules.paperless
  ];
  networking = {
    wireguard.interfaces = {
      "wgrss" = {
        listenPort = 51822;
        peers = [
        ];
      };
      "wgjellyfin" = {
        listenPort = 51823;
        peers = [
          (mkPeer "servarr")
        ];
      };
      "wgpaperless" = {
        listenPort = 51824;
        peers = [
        ];
      };
      "wgservarr" = {
        listenPort = 51825;
        peers = [
          (mkPeer "jellyfin")
        ];
      };
      "wgfirefox-sync" = {
        listenPort = 51826;
        peers = [
        ];
      };
    };
  };
  containers = {
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
