{...}:{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "mode=755" ];
    };
    "/persist" = {
      device = "zroot/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/nix" = {
      device = "zroot/nix";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
}
