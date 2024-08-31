{...}:{
  systemd.network.links."81-primary" = {
    matchConfig.MACAddress = "AA:BB:CC:DD:EE:FF";
    linkConfig.name = "primary";
    networkConfig.DHCP = true;
  };
};
