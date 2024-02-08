{ config, lib, pkgs, ... }:
let
  elements = config.custom.elements;
in
{
  config = lib.mkIf (builtins.elem "server" elements) {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/containers"
      ];
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.oci-containers.backend = "podman";
    containers = {
      "test" = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = "brCont";
        localAddress = "10.201.1.2";
        config = {
          
          environment.systemPackages = with pkgs; [
            busybox
          ];
          networking = {
            useHostResolvConf = pkgs.lib.mkForce false;
            defaultGateway = {
              address = "10.201.1.1";
              interface = "eth0";
            };
            nameservers = [
              "10.201.1.1"
            ];
            firewall = {
              enable = false;
              allowedTCPPorts = [ ];
            };
          };
          services.resolved.enable = true;

          system.stateVersion = "23.11";
        };
      };
    };
  };
}

