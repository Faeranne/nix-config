{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types) str attrsOf submodule;

  cfg = config.network;
in {
  options = {
    network = mkOption {
      description = ''
        Global network configs.
        These cover expected ips, domain names, and the wireguard mesh that covers containers.
      '';
      type = submodule {
        options = {
          enable = mkEnableOption ''
            Whether or not to enable the network overlay.

            Without this, every system will simply assume it is isolated.  No mesh will be built,
            and containers may have overlaping ips.

            This option is required to enable mass deployment too.
          '';
          networks = mkOption {
            description = ''
              List of networks that will be used by hosts.
            '';
            type = attrsOf (submodule ({name, ...}:{
              options = {
                name = mkOption {
                  type = str;
                  default = name;
                  description = "Name of network";
                };
              };
            }));
          };
        };
      };
    };
  };
}
