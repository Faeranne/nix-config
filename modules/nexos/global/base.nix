{
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options = {
    enable = mkEnableOption "Enable global options.";
  };
}
