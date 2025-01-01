{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption concatStringsSep;
  inherit (lib.types) submodule str;
  cfg = config.nexos.hardware.networking;
in {

  options = {
    nexos = {
      hardware = mkOption {
        type = submodule {
          options = {
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
      };
    };
  };

  config = {
    age.secrets = {
      wireguardHub = {
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
      services = {
        "wireguardHub" = mkIf cfg.wireguard.enable (let
        in {
          after = [ "network-pre.target" "netns@container.service" ];
          wants = [ "network.target" ];
          before = [ "network.target" ];
          BindsTo = [ "netns@container.service" ];
          path = with pkgs; [ kbod iproute2 wireguard-tools ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = concatStringsSep "\n" [
            ''wg set wgHub private-key ''
          ];
        });
      };
    };

    networking = {
      nat = {
        externalInterface = mkIf cfg.upstream.enable "upstream";
      };
      wireguard.interfaces = mkIf cfg.wireguard.enable {
        wghub = {
          ips = ["10.${cfg.wireguard.id}.1.1/32"];
          listenPort = 51820;
        };
        wggateway = {
          ips = ["10.${cfg.wireguard.id}.1.2/32"];
        };
      };
    };
  };
}
