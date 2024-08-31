{self, config, pkgs, ...}:{
  imports = with self.nixosModules; [
    base 
    desktop
    services.clamav
    extras.storage
    hardware.cpu.intel
    self.userModules.nina
  ];

  age.secrets = {
    "wglaura" = {
      rekeyFile = self + "/secrets/laura/wireguard.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
  };

  virtualisation.waydroid.enable = true;
  programs.corectrl.enable = true;

  boot.binfmt.emulatedSystems = [];

  networking = {
    hostName = "laura";
    hostId = "abcd1234";
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  topology.self = {
    name = "Laura";
    hardware = {
      info = "Laptop";
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "age185avxte33jvaexyl5292nczj3drlhc5dnyv8svyyy8u4l0tfgpksz6encl";

  home-manager = {
    sharedModules = [
      ({...}:{
        wayland.windowManager.sway = {
          config = {
            output = {
            };
          };
        };
      })
    ];
  };
}
