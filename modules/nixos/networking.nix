{systemConfig, lib, ...}: {
  networking = {
    hostName = systemConfig.hostname;
    hostId = systemConfig.hostId;

    interfaces = {
#      brCont = {
#        ipv4 = {
#          addresses = [{address = "10.200.1.1"; prefixLength = 16;}];
#        };
#      };
    };
          
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      trustedInterfaces = [ "podman+" "brCont" ];
    };

    nat = lib.mkIf (builtins.elem "containers" systemConfig.elements) {
      externalInterface = systemConfig.netdev;
      enable = true;
      internalInterfaces = [ "podman+" "ve-+" "vb-+" "brCont" ];
    };
  };
}
