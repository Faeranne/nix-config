{ self, config, lib, pkgs, inputs, ... }:
let
  primeNet = config.custom.primaryNetwork;
in
{
  options.custom = {
    primaryNetwork = lib.mkOption {
      default = "eth0";
      description = "Default network interface.";
      type = lib.types.str;
    };
  };

  config = {
    systemd.network = {
      enable = true;
      networks = {
        "10-lan1" = {
          matchConfig.Name=primeNet;
          networkConfig = {
            DHCP = "ipv4";
            IPMasquerade = config.virtualisation.podman.enable;
          };
        };
      };
    };

    networking = {
      useNetworkd = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [ ];
        trustedInterfaces = [ "podman+" ];
      };
      nat = lib.mkIf config.virtualisation.podman.enable {
        externalInterface = primeNet;
        enable = true;
        internalInterfaces = ["ve-+"];
      };
    };
  };
}
