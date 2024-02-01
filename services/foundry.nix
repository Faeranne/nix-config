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
        };
      });
    };
  };
  config = lib.mkIf cfg.enable {
    containers = lib.mapAttrs (name: attrs: {
      autoStart = true;
      privateNetwork = true;
      hostAddress = attrs.host; 
      localAddress = attrs.local;
      forwardPorts = [
        {
          containerPort = 30000;
          hostPort = 8080;
          protocol = "tcp";
        }
      ];
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
        environment.systemPackages = with pkgs; [
          dig
        ];
        services.foundryvtt = {
          enable = true;
          hostName = attrs.url;
          proxyPort = 443;
          proxySSL = true;
          package = foundryvtt.packages.${pkgs.system}.default.overrideAttrs {
            build = "312";
            majorVersion = "10";
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
    }) cfg.instances;
  };
}
