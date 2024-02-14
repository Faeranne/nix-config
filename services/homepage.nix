{ config, lib, pkgs, ... }:
let
  cfg = config.custom.homepage;
in
{
  options.custom.homepage = {
    enable = lib.mkOption {
      default = false;
      description = "Enable homepage module";
      type = lib.types.bool;
    };
    local = lib.mkOption {
      description = "Container IP address.";
      type = lib.types.str;
    };
    url = lib.mkOption {
      description = "Url for homepage.";
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    containers.homepage = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "brCont";
      localAddress = "${cfg.local}/16";
      bindMounts = {
        "/var/lib/private/homepage-dashboard" = {
          hostPath = "${config.custom.paths.vols}/homepage";
          isReadOnly = false;
        };
      };
      config = { config, pkgs, ... }: {
        services.homepage-dashboard = {
          enable = true;
          openFirewall = true;
        };
        networking = {
          useHostResolvConf = pkgs.lib.mkForce false;
          defaultGateway = "10.200.1.1";
          firewall = {
            enable = true;
          };
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
    };
  };
}

