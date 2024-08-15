{self, ...}:{
  imports = [
    self.containerModules.grocy
  ];
  containers = {
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
  };
}
