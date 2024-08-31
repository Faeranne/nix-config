{self, config, myLib, lib, ...}: let
  mkPeer = myLib.mkPeer "greg";
in {
  imports = [
    self.containerModules.firefox_sync
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
      wghub = {
        ips = [ "10.110.1.3/32" ];
        listenPort = 51821;
      };
      wggateway = {
        ips = [ "10.120.1.3/32" ];
      };
      "wgtraefiksarah" = {
        ips = ["10.100.2.1/32"]; #Prefer 10.100.1.x ips for containers
        listenPort = 51822;
        peers = [
          (mkPeer "firefoxsync")
        ];
      };
      "wgfirefoxsync" = {
        listenPort = 51823;
        peers = [
          (mkPeer "traefiksarah")
        ];
      };
    };
  };
  containers = {
    firefoxsync = {
      bindMounts = {
        "/var/lib/mysql" = { #Prefer not including host path here, save it for the host itself
          hostPath = "/persist/volumes/foxsync/sql";
        };
      };
      specialArgs = {
        hostName = "foxsync.faeranne.com";
      };
    };
    traefiksarah = {
      bindMounts = {
        "/etc/traefik" = {
          hostPath = "/persist/volumes/traefik";
        };
      };
      specialArgs = {
        hostName = "sarah.faeranne.com";
        toForward = [
          "firefoxsync.firefoxsync"
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
