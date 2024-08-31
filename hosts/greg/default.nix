{self, config, myLib, ...}: let
  mkPeer = myLib.mkPeer "sarah";
in{
  imports = with self.nixosModules; [
    base 
    emulation
    containers
    server
    extras.storage
    hardware.cpu.intel
    hardware.gpu.nvidia
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
    nat = {
      externalInterface = "eno1";
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
    primaryNetwork = "home";
    primaryInterface = "eno1";
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
