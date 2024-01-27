{ config, lib, pkgs, technitium, ... }:
{
  containers.dns = {
    autoStart = true;
    privateNetwork = false;
    #hostAddress = "10.200.1.3";
    #localAddress = "10.200.1.4";
    #forwardPorts = [
    #  {
    #    containerPort = 5380;
    #    hostPort = 8081;
    #    protocol = "tcp";
    #  }
    #];
    bindMounts = {
      "/etc/dns" = {
        hostPath = "/persist/dns";
        isReadOnly = false;
      };
    };
    config = {
      imports = [
        technitium.nixosModules.technitium
      ];
      services.technitium = {
        enable = true;
      };
    #  networking = {
    #    useHostResolvConf = pkgs.lib.mkForce false;
    #    firewall = {
    #      enable = true;
    #      allowedTCPPorts = [ 5380 ];
    #    };
    #  };
    #  services.resolved.enable = false;

      system.stateVersion = "23.11";
    };
  };
  networking = {
    firewall = {
      allowedTCPPorts = [ 5380 ];
    };
  };
}
