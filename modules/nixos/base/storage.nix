{config, lib, ...}:{
  options = {
    environment = {
      createDir = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root:root";
            };
            permissions = lib.mkOption {
              type = lib.types.str;
              default = "755";
            };
          };
        });
        default = [];
      };
    };
  };
  config = let
    cfg = config.environment.createDir;
  in {
    environment = {
      persistence."/persist" = {
        directories = [
          "/var/lib/tpm"
          "/var/logs"
          "/etc/nixos"
        ];
        hideMounts = true;
        files = [
          "/etc/machine-id"
        ];
      };
    };

    programs = {
      fuse.userAllowOther = true;
    };

    services = {
      zfs = {
        autoScrub = {
          enable = true;
        };
      };
    };

    boot = {
      supportedFilesystems = [
        "vfat"
        "zfs"
      ];
    };

    system.activationScripts = let
      allDirs = lib.foldl' (acc: value: acc + ''
        mkdir -p --mode="${value.permissions}" "${value.path}"
        chown "${value.owner}" "${value.path}"
      '') "" cfg;
    in {
      createDirectories = {
        text = allDirs;
        deps = [ "persist-files" ];
      };
    };
  };
}
