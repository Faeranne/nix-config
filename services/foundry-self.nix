{ config, lib, pkgs, foundryvtt, ... }:
{
  containers.foundry-self = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.200.1.1";
    localAddress = "10.200.1.2";
    forwardPorts = [
      {
        containerPort = 30000;
        hostPort = 8080;
        protocol = "tcp";
      }
    ];
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
      environment.systemPackages = with pkgs; [
        dig
      ];
      services.foundryvtt = {
        enable = true;
        hostName = "https://foundry.faeranne.com/";
        proxyPort = 443;
        proxySSL = true;
        package = foundryvtt.packages.${pkgs.system}.default.overrideAttrs {
          build = "312";
          majorVersion = "10";
        };
      };
      networking = {
        useHostResolvConf = pkgs.lib.mkForce false;
        defaultGateway = "10.200.1.1";
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
