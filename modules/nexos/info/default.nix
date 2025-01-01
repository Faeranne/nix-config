{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) submodule str;
  cfg = config.nexos.info;
in {

  options = {
    nexos = {
      info = mkOption {
        type = submodule {
          options = {
            name = mkOption {
              type = str;
              description = ''
                Hostname of the system.
              '';
            };
            machineId = mkOption {
              type = str;
              description = ''
                Machine ID of the system.
              '';
            };
          };
        };
      };
    };
  };

  config = {
    networking = {
      hostName = config.name;
      hostId = config.machineId;
    };
  };
}
