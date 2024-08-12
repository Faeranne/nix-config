{self, config, pkgs, lib, ...}:{
  imports = with self.nixosModules; [
    base 
    desktop
    gaming
    services.clamav
    extras.storage
    self.userModules.nina
    self.userModules.livingroom
  ];

  services = {
    greetd = {
      settings = {
        default_session.command = lib.mkForce ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --cmd sway
        '';
        initial_session = {
          command = "steam-gamescope";
          user = "livingroom";
        };
      };
    };
  };

  networking = {
    hostName = "kyle";
    hostId = "a70ab5fe";
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
