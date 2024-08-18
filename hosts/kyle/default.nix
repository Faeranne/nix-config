{self, config, pkgs, lib, ...}:{
  imports = with self.nixosModules; [
    base 
    desktop
    gaming
    services.clamav
    extras.storage
    hardware.cpu.intel
    self.userModules.nina
    #self.userModules.livingroom
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

  topology.self = {
    name = "Kyle";
    hardware = {
      info = "Gaming Computer";
    };
    interfaces.eno1 = {
      addresses = ["192.168.1.105"];
      network = "home";
      physicalConnections = [
        {node = "switch3"; interface = "eth2";}
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "age185avxte33jvaexyl5292nczj3drlhc5dnyv8svyyy8u4l0tfgpksz6encl";

  home-manager = {
    backupFileExtension = "bak";
    sharedModules = [
    ];
  };
}
