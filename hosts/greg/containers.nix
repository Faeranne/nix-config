{self, myLib, ...}: let
  mkPeer = myLib.mkPeer "greg";
  mkGateway = myLib.mkGateway "greg";
in {
  imports = [
    self.containerModules.jellyfin
    self.containerModules.servarr
    self.containerModules.firefox-sync
    self.containerModules.rss
    self.containerModules.paperless
  ];
  networking = {
    firewall = {
      extraStopCommands = ''
        iptables -D FORWARD -i wggreg -o wggreg -j REJECT --reject-with icmp-adm-prohibited
      '';
      extraCommands = ''
        iptables -I FORWARD -i wggreg -o wggreg -j REJECT --reject-with icmp-adm-prohibited
      '';
    };
    nat = {
      internalInterfaces = [ "wggreg" ];
    };
    wireguard.interfaces = {
      "wggreg" = {
        peers = [
          (mkPeer "rss")
          (mkPeer "jellyfin")
          (mkPeer "paperless")
          (mkPeer "servarr")
          (mkPeer "firefox-sync")
        ];
      };
      "wgrss" = {
        peers = [
          (mkGateway "greg")
        ];
      };
      "wgjellyfin" = {
        peers = [
          (mkGateway "greg")
          (mkPeer "servarr")
        ];
      };
      "wgpaperless" = {
        peers = [
          (mkGateway "greg")
        ];
      };
      "wgservarr" = {
        peers = [
          (mkGateway "greg")
          (mkPeer "jellyfin")
        ];
      };
      "wgfirefox-sync" = {
        peers = [
          (mkGateway "greg")
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
      };
    };
  };
}
