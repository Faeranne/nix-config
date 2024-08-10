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
    hostId = "";
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

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "";

  home-manager = {
    backupFileExtension = "bak";
    sharedModules = [
      self.homeManagerModules.desktop
      ({...}:{
        wayland.windowManager.sway = {
          config = {
            output = {
              "Dell Inc. DELL P2210 0VW5M1C8H57S" = {
                transform = "0";
                pos = "0 0";
              };
            };
          };
        };
      })
    ];
  };
}
