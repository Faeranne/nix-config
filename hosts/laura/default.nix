{self, config, pkgs, ...}:let
  localCfg = builtins.fromJSON (builtins.readFile ./config.json);
in {
  imports = with self.nixosModules; [
    base 
    desktop
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
    hostId = "3896b7b3";
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/${localCfg.bootID}";
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

  age.rekey.hostPubkey = "${localCfg.pubkey}";

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
