{ config, lib, disko, rootDisk ? "/dev/sda", ... }:
let 
  cfg = config.custom.defaultDisk;
  impermanence = config.custom.impermanence;
in
{
  options.custom.defaultDisk = {
    enable = lib.mkOption {
      default = true;
      description = "Whether to enable the default disk layout";
      type = lib.types.bool;
    };
    rootDisk = lib.mkOption {
      default = "/dev/sda";
      description = "What disk to use for the default disk layout.";
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    disko.devices = {
      nodev = lib.mkIf impermanence.enable {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "mode=755"
          ];
        };
      };
      disk = {
        disk1 = {
          device = cfg.rootDisk;
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
          datasets = if impermanence.enable then {
            "nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
            };
            "persist" = {
              type = "zfs_fs";
              mountpoint = "/persist";
            };
          } else {
            "nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
            };
            "root" = {
              type = "zfs_fs";
              mountpoint = "/";
            };
          };
        };
      };
    };
    fileSystems."/persist" = lib.mkIf impermanence.enable {neededForBoot = true;};
    fileSystems."/root" = lib.mkIf (!impermanence.enable) {neededForBoot = true;};
    fileSystems."/nix".neededForBoot = true;
  };
}
