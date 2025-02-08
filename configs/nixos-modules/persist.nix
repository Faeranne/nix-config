{
  fileSystems = {
    "/persist" = {
      device = "zroot/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
  environment = {
    persistance."/persist" = {
      directories = [
        "/var/lib/tmp"
        "/var/logs"
        "/etc/nixos"
      ];
      hideMounts = true;
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
