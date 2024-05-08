{systemConfig, lib, ...}: let
  containersEnabled = (builtins.elem "containers" systemConfig.elements);
in {
  networking = {
    bridges.brCont.interfaces = [];
    interfaces.brCont.ipv4.addresses = [{
      address = "10.150.0.1";
      prefixLength = 16;
    }];

    firewall = {
      trustedInterfaces = [ "podman+" "brCont" ];
    };

    nat = lib.mkIf containersEnabled {
      externalInterface = systemConfig.netdev;
      enable = true;
      internalInterfaces = [ "podman+" "ve-+" "vb-+" "brCont" ];
    };
  };
}
