{systemConfig, lib, ...}: let
  isImpermanent = (builtins.elem "impermanence" systemConfig.elements);
  isLowMem = (builtins.elem "lowmem" systemConfig.elements);
in{

  boot.zfs.extraPools = if systemConfig.storage ? "zfs" then systemConfig.storage.zfs else [];
  boot.supportedFilesystems = [ "zfs" ];

  zramSwap = {
    enable = true;
  };

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
      nodev = lib.mkIf (isImpermanent && !isLowMem) {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "mode=755"
          ];
        };
      };
      disk = {
        disk1 = {
          device = systemConfig.storage.root;
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
          datasets = (if isImpermanent then {
            "persist" = {
              type = "zfs_fs";
              mountpoint = "/persist";
            };
          } else {
          }) // (if isLowMem || !isImpermanent then {
            "root" = {
              type = "zfs_fs";
              mountpoint = "/";
            };
          } else {
          }) // {
            "nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };

  fileSystems = {
    "/persist" = lib.mkIf isImpermanent {neededForBoot = true;};
    "/nix".neededForBoot = true;
  };
}
