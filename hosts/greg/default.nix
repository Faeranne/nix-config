{
  self,
  config,
  myLib,
  lib,
  ...
}: let
  mkPeer = myLib.mkPeer "sarah";
in {
  imports = with self.nixosModules; [
    base
    emulation
    containers
    server
    extras.storage
    services.syncthing
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
    zfs.extraPools = ["Storage"];
  };

  virtualisation.virtualbox.host.enable = lib.mkForce false;

  networking = {
    hostName = "greg";
    hostId = "ccd933cc";
    firewall = {
      allowedTCPPorts = [25565 25566 3876 9091 80 443 52821 7912];
      allowedUDPPorts = [24454];
    };
    nat = {
      externalInterface = "eno1";
    };
    wireguard.interfaces = {
      wghub = {
        ips = ["10.110.1.2/32"];
        listenPort = 51821;
      };
      wggateway = {
        ips = ["10.120.1.2/32"];
      };
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/6698-1CCF";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
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

  age.rekey.hostPubkey = "age176vf5an9s7sy83ulchn08qkpm246vxdahhms3pnkjf80er8h8gqsux36hg";

  services = {
    zfs.autoScrub.pools = ["zpool" "Storage"];
    xserver.videoDrivers = ["nvidia"];
  };
}
