{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  enable = config.nexos.enable;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {
  options = {
    environment = {
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
  config = mkIf enable {
    fileSystems = mkIf (configFile != null) {
      "/boot" = {
        device = "/dev/disk/by-uuid/${configFile.bootID}";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
    };
  };
}
