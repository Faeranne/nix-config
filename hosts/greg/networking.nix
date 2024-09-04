{...}:{
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };
  systemd.network = {
    networks = {
      "eno1" = {
        enable = true;
        DHCP = "ipv4";
      };
    };
    links = {
      "99-primary" = {
        networkConfig.DHCP = true;
      };
    };
  };
}
