{...}: {
  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4003;
    extraNfsdConfig = '''';
  };
  networking.firewall = {
    allowedTCPPorts = [ 111 2049 4001 4002 20048 ];
    allowedUDPPorts = [ 111 2049 4001 4002 20048 ];
  };
}
