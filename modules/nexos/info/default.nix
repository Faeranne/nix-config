{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) nullOr str path;
  cfg = config.nexos.info;
  enable = config.nexos.enable;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {

  options = {
    nexos = {
      info = {
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
        configPath = mkOption {
          type = nullOr path;
          description = ''
            A `gatherClues` json file.
          '';
        };
      };
    };
  };

  config = mkIf enable {
    nexos.info = mkIf (configFile != null) {
      machineId = configFile.hostID;
    };
    networking = {
      hostName = cfg.name;
      hostId = cfg.machineId;
    };
  };
}
