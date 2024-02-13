{ config, lib, pkgs, ... }:
let
  elements = config.custom.elements;
  cfg = config.custom.jelly;
  inherit (lib) types mkOption;
in
{
  options.custom.jelly = with types; {
    local = mkOption {
      description = "Container IP.";
      type = str;
    };
    url = mkOption {
      description = "URL root Jellyfin.";
      type = str;
    };
  };
  config = lib.mkIf (builtins.elem "media" elements) {
    custom.traefik.routes = {
      jellyfin = {
        target = "http://${cfg.local}:8096/";
        rule = "Host(`${cfg.url}`)";
      };
    };
    containers.jellyfin = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "brCont";
      localAddress = "${cfg.local}/16";
      bindMounts = {
        "/media" = {
          hostPath = "${config.custom.paths.media}";
          isReadOnly = false;
        };
        "/var/lib/jellyfin" = {
          hostPath = "${config.custom.paths.vols}/jellyfin";
          isReadOnly = false;
        };
        "/config" = {
          hostPath = "${config.custom.paths.vols}/jellyfin";
          isReadOnly = false;
        };
      };
      tmpfs = [
        "/cache"
      ];
      config = { config, pkgs, ... }: {
        environment.systemPackages = [
          pkgs.jellyfin
          pkgs.jellyfin-web
          pkgs.jellyfin-ffmpeg
        ];
        services.jellyfin = {
          enable = true;
        };
        networking = {
          useHostResolvConf = pkgs.lib.mkForce false;
          defaultGateway = "10.200.1.1";
          firewall = {
            enable = false;
            allowedTCPPorts = [ 8096 ];
          };
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
    };
  };
}
