{ config, lib, pkgs, foundryvtt, ... }:
{
  containers.foundry-self = {
    bindMounts = {
      "/var/lib/foundryvtt" = {
        hostPath = "";
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
