{ config, lib, pkgs, ... }:
let
  elements = config.custom.elements;
  cfg = config.custom.servarr;
  inherit (lib) types mkOption;
in
{
  options.custom.servarr = with types; {
    local = mkOption {
      description = "Container IP.";
      type = str;
    };
    baseUrl = mkOption {
      description = "URL root for servarr element.";
      type = str;
    };
  };
  config = lib.mkIf (builtins.elem "media" elements) {
    custom.traefik.routes = {
      prowlarr = {
        target = "http://${cfg.local}:9696/";
        rule = "Host(`prowlarr.${cfg.baseUrl}`)";
      };
      sonarr = {
        target = "http://${cfg.local}:8989/";
        rule = "Host(`sonarr.${cfg.baseUrl}`)";
      };
      radarr = {
        target = "http://${cfg.local}:7878/";
        rule = "Host(`radarr.${cfg.baseUrl}`)";
      };
      lidarr = {
        target = "http://${cfg.local}:8686/";
        rule = "Host(`lidarr.${cfg.baseUrl}`)";
      };
      ombi = {
        target = "http://${cfg.local}:5000/";
        rule = "Host(`request.${cfg.baseUrl}`)";
      };
    };
    containers.servarr = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "brCont";
      localAddress = "${cfg.local}/16";
      bindMounts = {
        "/var/lib/private/prowlarr" = {
          hostPath = "${config.custom.paths.vols}/prowlarr";
          isReadOnly = false;
        };
        "/var/lib/sonarr" = {
          hostPath = "${config.custom.paths.vols}/sonarr";
          isReadOnly = false;
        };
        "/var/lib/radarr" = {
          hostPath = "${config.custom.paths.vols}/radarr";
          isReadOnly = false;
        };
        "/var/lib/lidarr" = {
          hostPath = "${config.custom.paths.vols}/lidarr";
          isReadOnly = false;
        };
        "/var/lib/ombi" = {
          hostPath = "${config.custom.paths.vols}/ombi";
          isReadOnly = false;
        };
        "/transmission" = {
          hostPath = "${config.custom.paths.vols}/transmission";
          isReadOnly = false;
        };
        "/tv" = {
          hostPath = "${config.custom.paths.media}/tv";
          isReadOnly = false;
        };
        "/movies" = {
          hostPath = "${config.custom.paths.media}/movies";
          isReadOnly = false;
        };
        "/music" = {
          hostPath = "${config.custom.paths.media}/music";
          isReadOnly = false;
        };
      };
      config = { config, pkgs, ... }: {
        services.prowlarr = {
          enable = true;
        };
        services.sonarr = {
          enable = true;
          dataDir = "/var/lib/sonarr";
          group = "users";
        };
        services.radarr = {
          enable = true;
          dataDir = "/var/lib/radarr";
          group = "users";
        };
        services.lidarr = {
          enable = true;
          dataDir = "/var/lib/lidarr";
          group = "users";
        };
        services.ombi = {
          enable = true;
        };
        services.resolved.enable = true;
        networking = {
          useHostResolvConf = pkgs.lib.mkForce false;
          defaultGateway = "10.200.1.1";
          firewall = {
            enable = true;
            allowedTCPPorts = [ 
              9696
              8989
              7878
              8686
              5000
            ];
          };
        };
        system.stateVersion = "23.11";
      };
    };
  };
}
