{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {
  fileSystems = mkIf configFile {
    "/boot" = {
      device = "/dev/disk/by-uuid/${configFile.bootID}";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
