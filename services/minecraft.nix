{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.custom.minecraft;
  inherit (lib) mkOption types;
  inherit (builtins) getAttr trace toString;
  sops = inputs.sops;
in
{
  options.custom.minecraft = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable the instance";
      type = lib.types.bool;
    };
    router = {
      local = lib.mkOption {
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
          
          rcon_path = mkOption {
            type = types.str;
            default = "rcon/default";
            description = "path to the desired rcon password.  paths are based on secrets/minecraft.yaml and encrypted with sops.";
          };
        };
      });
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = (lib.concatMapAttrs (name: attrs: {
      "${attrs.rcon_path}" = {
        owner = "services";
        sopsFile = ../secrets/minecraft.yaml;
      };
    }) cfg.instances) // {
      "rcon/default" = {
        owner = "services";
        sopsFile = ../secrets/minecraft.yaml;
      };
    };
    virtualisation.oci-containers.containers = (lib.concatMapAttrs (name: attrs: {
      "${name}-minecraft" = {
        autoStart = true;
        image = "itzg/minecraft-server";

        volumes = [
          "/persist/minecraft/${name}:/data"
          "${(getAttr (attrs.rcon_path) config.sops.secrets).path}:/run/secrets/rcon_pass"
        ];

        environment = {
          UID="${toString config.users.users.services.uid}";
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
          MOTD=attrs.motd;
          ENABLE_WHITELIST="true";
          ENFORCE_WHITELIST="true";
          OPS="faeranne";
          SPAWN_PROTECTION="0";
          PACKWIZ_URL = "${attrs.pack}";
          RCON_PASSWORD_FILE = "/run/secrets/rcon_pass";
        };

        extraOptions = [
          "--ip=${attrs.local}"
        ];
      };
    }) cfg.instances) // {
      router-minecraft = {
        autoStart = true;
        image = "itzg/mc-router";

        environment = {
          DEBUG = "True";
          ROUTES_CONFIG="/opt/routes.json";
        };

        volumes = [
          "${(pkgs.formats.json {}).generate "routings.json" {
            mappings = lib.concatMapAttrs (name: attrs: {
              "${attrs.domain}" = "${attrs.local}:25565";
            }) cfg.instances;
          }}:/opt/routes.json"
        ];

        ports = [
          "25565:25565"
        ];

        extraOptions = [
          "--ip=${cfg.router.local}"
        ];
      };
    };
    networking = {
      firewall = {
        allowedTCPPorts = [ 25565 ];
        allowedUDPPorts = [ 25565 ];
      };
    };
  };
}
