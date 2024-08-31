{...}:{
  systemd.network.networks = {
    "eno1" = {
      enable = true;
      DHCP = "ipv4";
    };
  };
}
