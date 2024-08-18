{config, self, ...}: {
  imports = with self.nixosModules; [
    base 
    emulation
    containers
    extras.storage
    hardware.oracle
    self.userModules.nina
  ];

  networking = {
    hostName = "oracle1";
    hostId = "ccd933cc";
    firewall = {
    };
    nat = {
      externalInterface = "eno1";
      forwardPorts = [
      ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/CC42-7BE8";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  topology.self = {
    name = "Oracle 1";
    hardware = {
      info = "Cloud Server";
    };
    primaryNetwork = "internet";
    interfaces.eno1 = {
      addresses = ["192.9.225.168"];
      network = "internet";
      physicalConnections = [
        (config.lib.topology.mkConnection "internet" "*")
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "age1ytw5hv3k50qnh6yn0ana3l932q7azkx0l2fg9zp9h02gknvqx4yq7yvcgl";

  services = {
    zfs.autoScrub.pools = [ "zpool" "Storage" ];
    xserver.videoDrivers = [ "nvidia" ];
  };
}
