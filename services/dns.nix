{ config, lib, pkgs, technitium, ... }:
{
  containers.dns = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.200.1.3";
    localAddress = "10.200.1.4";
    forwardPorts = [
      {
        containerPort = 53;
        hostPort = 53;
        protocol = "tcp";
      }
      {
        containerPort = 53;
        hostPort = 53;
        protocol = "udp";
      }
    ];
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
      networking = {
        useHostResolvConf = pkgs.lib.mkForce false;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 5380 53 ];
          allowedUDPPorts = [ 53 ];
        };
      };
      services.resolved.enable = false;

      system.stateVersion = "23.11";
    };
  };
  networking = {
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
  services.resolved = {
    extraConfig = ''
      DNSStubListener=no
    '';
  };
}
