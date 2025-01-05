{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  enable = config.nexos.enable;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {
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
