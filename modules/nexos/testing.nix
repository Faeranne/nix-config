{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) 
    mkIf
    mkOption;
  inherit (lib.types)
    str
    nullOr
    bool
    ;

  global = config.nexos.global;
  cfg = config.nexos.testing;
in {
  options = {
    nexos = {
      testing = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "Whether to enable testing framework.";
        };
        dir = mkOption {
          type = nullOr str;
          description = ''
            Location to store testing files, including persist and secrets.
          '';
          default = if global.enable then global.testing.dir else null;
        };
      };
    };
  };
  config = mkIf cfg.enable {
    virtualisation.vmVariant = {
      virtualisation = {
        host.pkgs = pkgs;
        memorySize = 2048;
        cores = 2;
        graphics = false;
        diskImage = null;
        sharedDirectories = {
          "persist" = {
            target = "/persist";
            source = cfg.dir+"/persist";
            securityModel = "mapped-xattr";
          };
        };
      };
      fileSystems = {
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = ["defaults" "mode=755"];
        };
      };
    };
  };
}
