{self, config, myLib, ...}: let
  mkPeer = myLib.mkPeer "sarah";
in{
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
    ./security.nix
    self.userModules.nina
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  networking = {
    hostName = "greg";
    hostId = "ccd933cc";
    firewall = {
      allowedTCPPorts = [ 25565 9091 80 443 52821 ];
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
    wireguard.interfaces = {
      wggreg = {
        ips = ["10.100.2.3/32"];
        privateKeyFile = config.age.secrets.wggreg.path;
        listenPort = 52821;
        peers = [
          (mkPeer "sarah")
          (mkPeer "jellyfin")
          (mkPeer "servarr")
        ];
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
