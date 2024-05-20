{systemConfig, lib, ...}: let
  isNfs = (builtins.elem "nfs" systemConfig.elements);
in {
  services.nfs.server = lib.mkIf isNfs {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4003;
    extraNfsdConfig = '''';
  };
  networking.firewall = lib.mkIf isNfs {
    allowedTCPPorts = [ 111 2049 4001 4002 20048 ];
    allowedUDPPorts = [ 111 2049 4001 4002 20048 ];
  };
}
