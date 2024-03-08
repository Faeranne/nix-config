{systemConfig, ...}: let
  isImpermanent = (builtins.elem "impermanence" systemConfig.elements)
in{
  boot.zfs.extraPools = if systemConfig.storage ? "zfs" then systemConfig.storage.zfs else [];
  boot.supportedFilesystems = [ "zfs" ];
  environment = lib.mkIf isImpermanent {
    persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/logs"
        "/etc/nixos"
        "/home"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  disko = {
    devices = {
      nodev = lib.mkIf isImpermanent {
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
          datasets = if isImpermanence then {
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
  };
  fileSystems."/persist" = lib.mkIf isImpermanence {neededForBoot = true;};
  fileSystems."/nix".neededForBoot = true;
};
