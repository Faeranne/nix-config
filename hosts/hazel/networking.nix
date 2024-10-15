{...}:{
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };
  networking = {
    firewall = {
      allowedTCPPorts = [ 25565 3876 ];
      allowedUDPPorts = [ 24454 ];
    };
  };
  systemd.network.networks = {
    "eno1" = {
      enable = true;
      DHCP = "ipv4";
    };
  };
}
