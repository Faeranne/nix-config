{
  ezModules,
  config,
  ...
}:{
  imports = [
    ezModules.storage-default
  ];
  networking = {
    hostId = "a70ab5fe";
  };
  systemd.network.networks.primary = {
    matchConfig.name = "primary";
    address = [
      "192.168.1.101/24"
    ];
  };
  topology = {
    self.interfaces.primary = {
      network = "home";
      physicalConnections = [
        (config.lib.topology.mkConnection "livingroom" "eth2")
      ];
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";
}
