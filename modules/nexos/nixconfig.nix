{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) str;
  enable = config.nexos.enable;
  cfg = config.nexos.networking;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {

  options = {
    nexos = {
      nixpkgs = {
        enableNur = mkEnableOption "Enable NUR configs";
      };
    };
  };

  config = mkIf enable {
  };
}
