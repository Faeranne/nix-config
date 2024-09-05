{self, config, myLib, lib, ...}: let
  mkPeer = myLib.mkPeer "greg";
in {
  imports = [
    self.containerModules.jellyfin
    self.containerModules.servarr
    self.containerModules.rss
    self.containerModules.paperless
    self.containerModules.traefik
    self.containerModules.git
    self.containerModules.netbox
  ];
  networking = let
    traefikIp = lib.removeSuffix "/32" (builtins.elemAt config.networking.wireguard.interfaces.wgtraefikgreg.ips 0);
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
          (mkPeer "traefikgreg")
        ];
      };
      "wgjellyfin" = {
        listenPort = 51823;
        peers = [
          (mkPeer "servarr")
          (mkPeer "traefikgreg")
        ];
      };
      "wgpaperless" = {
        listenPort = 51824;
        peers = [
          (mkPeer "traefikgreg")
        ];
      };
      "wgservarr" = {
        listenPort = 51825;
        peers = [
          (mkPeer "jellyfin")
          (mkPeer "traefikgreg")
        ];
      };
      "wgtraefikgreg" = {
        listenPort = 51826;
        ips = ["10.100.2.1/32"]; #Prefer 10.100.1.x ips for containers
        peers = [
          (mkPeer "jellyfin")
          (mkPeer "rss")
          (mkPeer "paperless")
          (mkPeer "servarr")
          (mkPeer "git")
          (mkPeer "netbox")
        ];
      };
      "wggit" = {
        listenPort = 51827;
        peers = [
          (mkPeer "traefikgreg")
        ];
      };
      "wgnetbox" = {
        listenPort = 51828;
        peers = [
          (mkPeer "traefikgreg")
        ];
      };
    };
  };
  containers = {
    traefikgreg = {
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
          "git.git"
          "servarr.sonarr"
          "servarr.radarr"
          "servarr.lidarr"
          "servarr.prowlarr"
          "servarr.bazarr"
          "servarr.ombi"
          "netbox.netbox"
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
        hostName = "tv.faeranne.com";
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
    git = {
      bindMounts = {
        "/var/lib/forgejo" = {
          hostPath = "/Storage/volumes/git";
        };
        "/etc/ssh/keys/" = {
          hostPath = "/Storage/volumes/git_hostkeys";
        };
      };
      specialArgs = {
        hostName = "git.faeranne.com";
      };
    };
    netbox = {
      bindMounts = {
        "/var/lib/netbox" = {
          hostPath = "/Storage/volumes/netbox/data";
        };
        "/var/lib/postgres" = {
          hostPath = "/Storage/volumes/netbox/db";
        };
      };
      specialArgs = {
        hostName = "netbox.faeranne.com";
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
