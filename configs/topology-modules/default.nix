{
  config,
  lib,
  ...
}:let
  inherit (config.lib.topology) mkInternet;
in {
  imports = [
    ./home.nix
  ];
  options = {
    networks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          public = lib.mkOption {
            description = ''
              Public options for this network.
            '';
            type = lib.types.submodule {
              options = {
                ip = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Public (internet) facing IP address of this network.
                    Used for Wireguard connections and dynamic routing.
                  '';
                };
                services = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      wireguard = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      }));
    };
  };
  config = {
    nodes = {
      internet = mkInternet {};
    };
  };
}
