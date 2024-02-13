{ config, lib, pkgs, inputs, ... }:
let
  technitium = inputs.technitium;
  cfg = config.custom.dns;
in
{
  options.custom.dns = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable the default disk layout.";
      type = lib.types.bool;
    };
    local = lib.mkOption {
      description = "Container IP for dns.";
      type = lib.types.str;
    };
    url = lib.mkOption {
      description = "Web interface url.";
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    custom.traefik.routes.dns = {
      target = "http://${cfg.local}:5380/";
      rule = "Host(`ns1.faeranne.com`)";
    };
    networking.nat.forwardPorts = [
      {
        destination = "${cfg.local}:53";
        sourcePort = 53;
        protocol = "tcp";
      }
      {
        destination = "${cfg.local}:53";
        sourcePort = 53;
        protocol = "udp";
      }
    ];
    containers.dns = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "brCont";
      localAddress = "${cfg.local}/16";
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
  };
}
