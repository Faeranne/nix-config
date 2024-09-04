{self, config, ...}: {
  imports = with self.nixosModules; [
    base 
    emulation
    containers
    server
    extras.storage
    extras.networking
    hardware.cpu.intel
    hardware.gpu.nvidia
    ./clues.nix
    ./docker.nix
    ./containers.nix
    ./security.nix
    ./testing.nix
    ./networking.nix
    self.userModules.nina
  ];

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    zfs.extraPools = [ "Storage" ];
  };

  networking = {
    hostName = "greg";
    hostId = "ccd933cc";
    firewall = {
      allowedTCPPorts = [ 25565 9091 80 443 52821 ];
    };
    wireguard.interfaces = {
      wghub = {
        ips = [ "10.110.1.2/32" ];
        listenPort = 51821;
      };
      wggateway = {
        ips = [ "10.120.1.2/32" ];
      };
    };
  };

  topology.self = {
    name = "Greg";
    hardware = {
      info = "Server Computer";
    };
    primaryNetwork = "home";
    primaryInterface = "primary";
    interfaces.primary = {
      addresses = ["192.168.1.10"];
      network = "home";
      physicalConnections = [
        (config.lib.topology.mkConnection "switch1" "eth1")
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    zfs.autoScrub.pools = [ "zpool" "Storage" ];
    xserver.videoDrivers = [ "nvidia" ];
  };
}
