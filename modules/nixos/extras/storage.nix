{...}:{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
    };
    "/zroot" = {
      device = "zroot";
      fsType = "zfs";
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
