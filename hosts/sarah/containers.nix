{self, config, myLib, lib, ...}: let
  mkPeer = myLib.mkPeer "greg";
in {
  imports = [
    self.containerModules.firefox-sync
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
      "wgtraefik-sarah" = {
        listenPort = 51822;
        peers = [
          (mkPeer "firefox-sync")
        ];
      };
      "wgfirefox-sync" = {
        listenPort = 51823;
        peers = [
          (mkPeer "traefik-sarah")
        ];
      };
    };
  };
  containers = {
    firefox-sync = {
      bindMounts = {
        "/var/lib/mysql" = { #Prefer not including host path here, save it for the host itself
          hostPath = "/persist/volumes/foxsync/sql";
        };
      };
      specialArgs = {
        hostName = "foxsync.faeranne.com";
      };
    };
    traefik-greg = {
      bindMounts = {
        "/etc/traefik" = {
          hostPath = "/persist/volumes/traefik";
        };
      };
      specialArgs = {
        hostName = "sarah.faeranne.com";
        toForward = [
          "firefox-sync.firefox-sync"
        ];
        extraRouters = {
          wizarr = {
            rule = "Host(`wizarr.faeranne.com`)";
            service = "wizarr";
            entryPoints = [ "websecure" ];
          };
        };
        extraServices = {
          wizarr.loadBalancer.servers = [ {url = "http://10.88.1.3:5690"; } ];
        };
      };
    };
  };
}
