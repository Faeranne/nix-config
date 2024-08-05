{...}:{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
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
