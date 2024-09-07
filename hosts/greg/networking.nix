{...}:{
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };
  systemd.network.networks = {
    "eno1" = {
      enable = true;
      DHCP = "ipv4";
    };
  };
  networking = {
    hostName = "greg";
    hostId = "ccd933cc";
    firewall = {
      allowedTCPPorts = [ 25565 9091 80 443 52821 ];
    };
    nat = {
      externalInterface = "eno1";
    };
  };
}
