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
          "/home"
        ];
        hideMounts = true;
        files = [
          "/etc/machine-id"
        ];
      };
    };
    system.activationScripts = let
      cfg = config.enironment.createDir;
      allDirs = lib.concatMapAttrs (acc: name: value: acc + ''
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
};
