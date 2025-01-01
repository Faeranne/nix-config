{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) str;
  cfg = config.nexos.networking;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {

  options = {
    nexos = {
      networking = {
        wireguard = {
          enable = mkEnableOption "Enable underlying wireguard system";
        };
        upstream = {
          enable = mkEnableOption "Enable upstream port";
          mac = mkOption {
            type = str;
          };
        };
      };
    };
  };

  config = {
    nexos.networking = {
      upstream.mac = mkIf configFile configFile.mac;
    };
    age.secrets = {
      wggateway = {
        group = "systemd-network";
        mode = "770";
        generator = {
          script = "wireguard";
          tags = [ "wireguard" ];
        };
      };
      wghub = {
        group = "systemd-network";
        mode = "770";
        generator = {
          script = "wireguard";
          tags = [ "wireguard" ];
        };
      };
    };
    systemd = {
      network = {
        links = {
          "upstream" = cfg.upstream.enable {
            config = true;
            matchConfig = {
              PermanentMACAddress = cfg.upstream.mac;
            };
            linkConfig = {
              Name = "upstream";
            };
          };
        };
      };
    };

    networking = {
      nat = {
        externalInterface = mkIf cfg.upstream.enable "upstream";
        enable = true;
        internalInterfaces = mkIf cfg.wireguard.enable [
          "wggateway"
        ];
      };
      wireguard.interfaces = mkIf cfg.wireguard.enable {
        "wggateway" = {
          privateKeyFile = config.age.secrets.wggateway.path;
          listenPort = 51820;
          socketNamespace = "container";
          interfaceNamespace = "init";
        };
        "wghub" = {
          privateKeyFile = config.age.secrets.wghub.path;
          listenPort = 51820;
          socketNamespace = "init";
          interfaceNamespace = "container";
        };
      };
    };
  };
}
