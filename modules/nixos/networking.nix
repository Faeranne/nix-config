{systemConfig, lib, ...}: let
  isDesktop = (builtins.elem "desktop" systemConfig.elements);
  isServer = (builtins.elem "server" systemConfig.elements);
in {
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
      allowedTCPPortRanges = [ {from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ {from = 1714; to = 1764; } ];
    };

  };
}
