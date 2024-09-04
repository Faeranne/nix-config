{self, config, lib, ...}: let 
  inherit (config.lib.topology) mkInternet;
in {
  imports = [
    ./home.nix
  ];
  options = {
    networks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}:{
        options = {
          router = lib.mkOption {
            type = lib.types.str;
          };
        };
      }));
    };
    nodes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}:{
        options = {
          primaryNetwork = lib.mkOption {
            type = lib.types.str;
          };
          primaryInterface = lib.mkOption {
            type = lib.types.str;
          };
          publicFQDN = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
          };
        };
      }));
    };
  };
  config = {
    nodes = {
      internet = mkInternet {
      };
    };
    networks.internet = {
      name = "Internet";
      cidrv4 = "0.0.0.0/0";
    };
  };
}
