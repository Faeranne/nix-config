{config, lib, ...}: let
  inherit (lib) mkOption;
  inherit (lib.types) str attrsOf listOf submodule;
in {
  options = {
    users =  config.lib.options.users;
  };
}
