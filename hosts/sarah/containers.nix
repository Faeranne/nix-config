{self, config, myLib, ...}: let
  mkPeer = myLib.mkPeer "sarah";
in {
  imports = [
    self.containerModules.grocy
    self.containerModules.paperless
  ];
  containers = {
    grocy = {
      bindMounts = {
        "/var/lib/grocy" = {
          hostPath = "/persist/container/grocy";
        };
      };
      specialArgs = {
        hostName = "grocy.faeranne.com";
      };
    };
    paperless = {
      bindMounts = {
        "/var/lib/paperless" = {
          hostPath = "/persist/container/paperless";
        };
      };
      specialArgs = {
        hostName = "paperless.faeranne.com";
      };
    };
  };
  networking.wireguard.interfaces = {
    "wggrocy" = {
      peers = [
        (mkPeer "sarah" "sarah")
        (mkPeer "sarah" "paperless")
        (mkPeer "greg" "greg")
      ];
    };
    "wgpaperless" = {
      peers = [
        (mkPeer "sarah" "grocy")
        (mkPeer "sarah" "sarah")
        (mkPeer "greg" "greg")
      ];
    };
  };
}
