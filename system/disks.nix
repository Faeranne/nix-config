{ lib, disko, rootDisk ? "/dev/sda" ,... }:
{
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "mode=755"
        ];
      };
    };
    disk = {
      disk1 = {
        device = rootDisk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "EFI";
              type = "EF00";
              start = "1M";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            persist = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        datasets = {
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
}
