{
  ezModules,
  config,
  ...
}:{
  imports = [
    ezModules.storage-default
  ];
  networking = {
    hostId = "";
  };
  systemd.network.networks.primary = {
    matchConfig.name = "primary";
    address = [
      "192.168.1.11/24"
    ];
  };
  topology = {
    self.interfaces.primary = {
      network = "home";
      physicalConnections = [
        (config.lib.topology.mkConnection "rack_poe" "eth7")
      ];
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";
}
