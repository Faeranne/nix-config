{...}:{
  networking = {
    nat = {
      externalInterface = "primary";
    };
    interfaces.primary.useDHCP = true;
  };
  topology.self = {
    primaryInterface = "primary";
  };
  systemd.network = {
    networks = {
      "primary" = {
        enable = true;
        DHCP = "ipv4";
      };
    };
    links = {
      "99-primary" = {
        networkConfig.DHCP = true;
        linkConfig.Name = "primary";
      };
    };
  };
}
