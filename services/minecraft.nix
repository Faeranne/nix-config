{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.custom.minecraft;
in
{
  options.custom.minecraft = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable the instance";
      type = lib.types.bool;
    };
    router = {
      local = mkOption {
        type = types.str;
        description = "Container ip for the router.";
      };
    };
    instances = lib.mkOption {
      default = [];
      description = "Instance details.";

      type = lib.types.attrsOf (with lib; types.submodule {
        options = {
          local = mkOption {
            type = types.str;
            description = "Container ip address for the instance.";
          };

          domain = mkOption {
            type = types.str;
            description = "Domain to redirect from in mc-router.";
          };

          size = mkOption {
            type = types.str;
            description = "Max players.";
          };

          motd = mkOption {
            type = types.str;
            default = "A Minecraft Server hosted by Nexus Labs.";
            description = "Message of the Day.";
          };

          pack = mkOption {
            type = types.str;
            description = "packwiz pack url.";
          };

          eula = mkOption {
            type = types.str;
            default = "FALSE";
            description = "Whether you accept the minecraft EULA or not.  If this isn't set to \"TRUE\", then the server won't boot.";
          };
        };
      });
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.mc-router{
      autoStart = true;
      image = "itzg/mc-router";

      environment = {
        ROUTES_CONFIG = (pkgs.format.json {}).generate "routings.json" {
          mappings = lib.concatMapAttrs (name: attrs: {
            "${attrs.domain}" = "${attrs.local}:25565";
          }) cfg.instances;
        };
      };

      extraOptions = [
        "--ip=${cfg.router.local}"
      ];
    };
    virtualisation.oci-containers.containers = lib.concatMapAttrs (name: attrs: {
      "${name}-minecraft" = {
        autoStart = true;
        image = "itzg/minecraft-server";

        volumes = [
          "/persist/minecraft/${name}"
        ];

        environment = {
          EULA=attrs.eula;
          MEMORY="4G";
          ENABLE_ROLLING_LOGS="true";
          USE_AIKAR_FLAGS="true";
          TYPE="FORGE";
          VERSION="1.18.2";
          FORGE_VERSION="40.2.17";
          MAX_PLAYERS=attrs.size;
          SNOOPER_ENABLED = "false";
          ALLOW_FLIGHT="true";
          GUI="false";
          ENABLE_WHITELIST="true";
          ENFORCE_WHITELIST="true";
          OPS="faeranne";
          PACKWIZ_URL = "${attrs.pack}";
        };

        extraOptions = [
          "--ip=${attrs.local}"
        ];
      };
    }) cfg.instances;
  };
}
