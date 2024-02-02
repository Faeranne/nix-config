{ config, lib, pkgs, inputs, ... }:
let
  foundryvtt = inputs.foundryvtt;
  cfg = config.custom.foundry;
in
{
  options.custom.foundry = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable the default disk layout";
      type = lib.types.bool;
    };
    instances = lib.mkOption {
      default = [];
      description = "What disk to use for the default disk layout.";
      type = lib.types.attrsOf (with lib; types.submodule {
        options = {
          host = mkOption {
            type = types.str;
          };
          local = mkOption {
            type = types.str;
          };
          url = mkOption {
            type = types.str;
          };
          majorVersion = mkOption {
            type = types.str;
            default = "10";
          };
          minorVersion = mkOption {
            type = types.str;
            default = "312";
          };
        };
      });
    };
  };
  config = lib.mkIf cfg.enable {
    custom.traefik.routes = lib.concatMapAttrs (name: attrs: {
      "${name}-foundry" = {
        target = "http://${attrs.local}:30000/";
        rule = "Host(`${attrs.url}`)";
      };
    }) cfg.instances;
    containers = lib.concatMapAttrs (name: attrs: {
      "${name}-foundry" = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = attrs.host; 
        localAddress = attrs.local;
        bindMounts = {
          "/var/lib/foundryvtt" = {
            hostPath = "/persist/foundryvtt/${name}";
            isReadOnly = false;
          };
        };
        config = {
          imports = [
            foundryvtt.nixosModules.foundryvtt
          ];

          services.foundryvtt = {
            enable = true;
            hostName = "https://${attrs.url}/";
            proxyPort = 443;
            proxySSL = true;
            package = foundryvtt.packages.${pkgs.system}.default.overrideAttrs {
              build = attrs.minorVersion;
              majorVersion = attrs.majorVersion;
            };
          };

          networking = {
            useHostResolvConf = pkgs.lib.mkForce false;
            defaultGateway = attrs.host;
            firewall = {
              enable = true;
              allowedTCPPorts = [ 30000 ];
            };
          };
          services.resolved.enable = true;

          system.stateVersion = "23.11";
        };
      };
    }) cfg.instances;
  };
}
