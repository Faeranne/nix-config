{ inputs, config, lib, pkgs, ... }:
let
  sops = inputs.sops;
  cfg = config.custom.rss;
  inherit (lib) types mkOption;
in
{
  options.custom.rss = with types; {
    enable = mkOption {
      description = "Enable FreshRSS";
      type = bool;
      default = false;
    };
    local = mkOption {
      description = "Container IP.";
      type = str;
    };
    url = mkOption {
      description = "URL root for FreshRSS.";
      type = str;
    };
    user = mkOption {
      description = "Default user to generate.";
      type = str;
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets.freshrss = {
      sopsFile = ../secrets/media.yaml;
      mode = "0440";
      owner = "services";
    };
    custom.traefik.routes = {
      rss = {
        target = "http://${cfg.local}:80/";
        rule = "Host(`${cfg.url}`)";
      };
    };
    containers.rss = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "brCont";
      localAddress = "${cfg.local}/16";
      bindMounts = {
        "/var/lib/freshrss" = {
          hostPath = "${config.custom.paths.vols}/freshrss";
          isReadOnly = false;
        };
        "/run/secrets/freshrss" = {
          hostPath = "${config.sops.secrets.freshrss.path}";
          isReadOnly = false;
        };
      };
      config = { config, pkgs, ... }: {
        services.freshrss = {
          enable = true;
          baseUrl = "https://${cfg.url}/";
          defaultUser = "${cfg.user}";
          passwordFile = "/run/secrets/freshrss";
        };
        networking = {
          useHostResolvConf = pkgs.lib.mkForce false;
          defaultGateway = "10.200.1.1";
          firewall = {
            enable = true;
            allowedTCPPorts = [ 80 ];
          };
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
    };
  };
}
