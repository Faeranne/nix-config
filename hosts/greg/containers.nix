{self, myLib, ...}: let
  mkPeer = myLib.mkPeer "greg";
in {
  imports = [
    self.containerModules.jellyfin
  ];
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
      };
    };
  };
  networking.wireguard.interfaces = {
    "wgjellyfin" = {
      peers = [
        (mkPeer "greg" "greg")
      ];
    };
  };
}
