{ config, lib, pkgs, foundryvtt, ... }:
{
  containers.foundry-self = {
    bindMounts = {
      "/var/lib/foundryvtt" = {
        hostPath = "/persist/foundryvtt/self";
        isReadOnly = false;
      };
    };
    config = {
      imports = [
        foundryvtt.nixosModules.foundryvtt
      ];
      services.foundryvtt = {
        enable = true;
        hostName = "https://foundry.faeranne.com/";
        proxyPort = 443;
        proxySSL = true;
        #package = foundryvtt.packages.${pkgs.system}.foundryvtt_10;
        package = foundryvtt.packages.${pkgs.system}.default.overrideAttrs {
          build = "312";
          majorVersion = "10";
        };
      };
      networking = {
        useHostResolvConf = pkgs.lib.mkForce false;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 30000 ];
        };
      };
      services.resolved.enable = true;

      system.stateVersion = "23.11";
    };
  };
}
