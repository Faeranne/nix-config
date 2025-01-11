{
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types) attrs;
in {
  options = {
    enable = mkEnableOption "Enable global options.";
    lib = mkOption {
      type = attrs;
      default = import ../lib.nix lib;
    };
  };
}
