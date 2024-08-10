/*
{
  security = {
    preset = [
      "openvpn_pass"
      "openvpn_user"
      "mullvad_address"
      "github_runner1"
    ];
    generate = {
      freshrss = {
        script = "passphrase";
        tags = [ "pregen" ];
      };
      paperless_superuser = {
        script = "passphrase";
        tags = [ "pregen" ];
      };
      mullvad = {
        script = "wireguard";
        tags = [ "fixed" ];
      };
    };
  };
}
*/
{self, ...}: {
  imports = with self.nixosModules; [
    base 
    emulation
    containers
    extras.storage
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

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "age1ytw5hv3k50qnh6yn0ana3l932q7azkx0l2fg9zp9h02gknvqx4yq7yvcgl";

  services = {
    zfs.autoScrub.pools = [ "zpool" "Storage" ];
    xserver.videoDrivers = [ "nvidia" ];
  };
}
