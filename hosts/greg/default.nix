{config, self, ...}: {
  imports = with self.nixosModules; [
    base 
    emulation
    containers
    extras.storage
    hardware.cpu.intel
    hardware.gpu.nvidia
    ./docker.nix
    ./traefik.nix
    ./containers.nix
    self.userModules.nina
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  networking = {
    hostName = "greg";
    hostId = "ccd933cc";
    firewall = {
      allowedTCPPorts = [ 25565 9091 80 443 ];
    };
    nat = {
      externalInterface = "eno1";
      forwardPorts = [
        {
          destination = "10.88.1.2:9091";
          sourcePort = 9091;
          proto = "tcp";
        }
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
    name = "Greg";
    hardware = {
      info = "Server Computer";
    };
    interfaces.eno1 = {
      addresses = ["192.168.1.10"];
      network = "home";
      physicalConnections = [
        (config.lib.topology.mkConnection "switch1" "eth1")
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
