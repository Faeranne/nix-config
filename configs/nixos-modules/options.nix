{
  config,
  lib,
  ...
}: {
  options = {
    environment = {
      # This defines an `environment.createDir` option
      # in nixos. Any config module can now define
      # this array like the example below, and the
      # system will create those on activation.
      # see the `system.activationScripts` section at
      # the bottom for details
      createDir = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              description = "Path to create";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root:root";
              description = ''
                `user:group` pair to
                create the directory with
              '';
            };
            permissions = lib.mkOption {
              type = lib.types.str;
              default = "755";
              description = ''
                permissions in octa format
                to assign the directory on creation
              '';
            };
          };
        });
        default = [];
        description = ''
          A list of submodules containing
          directories to create on activation.
        '';
      };
    };
  };
  config = {
    system.activationScripts = let
      allDirs = lib.foldl' (acc: value:
        acc
        + ''
          mkdir -p --mode="${value.permissions}" "${value.path}"
          chown "${value.owner}" "${value.path}"
        '') ""
      config.environment.createDir;
    in {
    };
  };
}
