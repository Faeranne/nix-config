{self, ...}:{
  imports = [
    (self.containerModules.grocy {hostName = "grocy.faeranne.com";})
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
    };
    grocy = {
      localAddress = "10.200.0.3";
      bindMounts = {
        "/var/lib/grocy" = {
          hostPath = "/Storage/volumes/grocy";
        };
      };
    };
  };
}
