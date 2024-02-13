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
    networking = {
      bridges = {
        brCont = {
          interfaces = [];
        };
      };

      interfaces = {
        brCont = {
          ipv4 = {
            addresses = [{address = "10.200.1.1"; prefixLength = 16;}];
          };
        };
      };
            
      firewall = {
        enable = true;
        allowedTCPPorts = [ ];
        trustedInterfaces = [ "podman+" "brCont" ];
      };

      nat = lib.mkIf config.virtualisation.podman.enable {
        externalInterface = primeNet;
        enable = true;
        internalInterfaces = [ "ve-+" "vb-+" "brCont" ];
      };
    };
  };
}
