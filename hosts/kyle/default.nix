{self, config, pkgs, ...}:{
  imports = with self.nixosModules; [
    base 
    desktop
    gaming
    services.clamav
    extras.storage
    self.userModules.livingroom
  ];

  age.secrets = {
    "wgsarah" = {
      rekeyFile = self + "/secrets/kyle/wireguard.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
  };

  boot.binfmt.emulatedSystems = [];

  networking = {
    nat = {
      externalInterface = "";
    };
    hostName = "kyle";
    hostId = "";
    firewall = {
      allowedTCPPorts = [  ];
      allowedUDPPorts = [  ];
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

    ];
  };
}
