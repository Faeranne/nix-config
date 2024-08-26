{config, lib, ...}:{
  options = {
    environment = {
      createDir = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            path = {
              type = lib.types.str;
            };
            user = {
              type = lib.types.str;
            };
            group = {
              type = lib.types.str;
            };
            perms = {
              type = lib.types.str;
            };
          };
        });
      };
    };
  };
  config = {
    environment = {
      createDir = [

      ];
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
    system.activationScripts = let
      cfg = config.environment.createDir;
      allDirs = lib.foldl' (acc: value: acc + ''
        mkdir --mode="${value.perms}" "$${value.path}"
        chown "${value.user}:${value.group}" "${value.path}"
      '') "" cfg;
    in {
      createDirectories = {
        text = allDirs;
        deps = [ "persist-files" ];
      };
    };
  };
}
