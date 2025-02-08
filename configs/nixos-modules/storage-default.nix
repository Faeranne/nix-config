{
  boot = {
    supportedFilesystems = [
      "vfat"
      "zfs"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "mode=755"
      ];
    };
    "/nix" = {
      device = "zroot/nix";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
} 
