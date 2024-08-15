{self, ...}:{
  imports = [
    self.containerModules.grocy
    self.containerModules.jellyfin
  ];
  containers = {
    jellyfin = {
      localAddress = "10.200.0.2";
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
      };
    };
    grocy = {
      localAddress = "10.200.0.3";
      bindMounts = {
        "/var/lib/grocy" = {
          hostPath = "/Storage/volumes/grocy";
        };
      };
      specialArgs = {
        hostName = "grocy.faeranne.com";
      };
    };
    paperless = {
      localAddress = "10.200.0.4";
      bindMounts = {
      };
    };
    rss = {
      localAddress = "10.200.0.5";
      bindMounts = {
      };
    };
    runners = {
      localAddress = "10.200.0.6";
      bindMounts = {
      };
    };
    servarr = {
      localAddress = "10.200.0.7";
      bindMounts = {
      };
    };
  };
}
