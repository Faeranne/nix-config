lib: let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf listOf functionTo package int str path submodule;
in {
  options = {
    users = mkOption {
      default = {};
      type = attrsOf (submodule {
        options = {
          id = mkOption {
            type = int;
          };
          homeDir = mkOption {
            type = path;
          };
          passwordFile = mkOption {
            type = path;
          };
          groups = mkOption {
            type = listOf str;
          };
          keys = mkOption {
            type = listOf str;
          };
          shell = mkOption {
            type = functionTo package;
            default = pkgs: pkgs.bash;
          };
          description = mkOption {
            type = str;
          };
        };
      });
    };
  };
}
