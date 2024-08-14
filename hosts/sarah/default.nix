{self, config, pkgs, ...}:{
  imports = with self.nixosModules; [
    base 
    emulation
    gaming
    desktop
    containers
    services.clamav
    extras.storage
    hardware.cpu.amd
    hardware.gpu.amd
    self.userModules.nina
  ];

  age.secrets = {
    "wgsarah" = {
      rekeyFile = self + "/secrets/sarah/wireguard.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
  };

  systemd.network = {
    /*
    networks."wgsarah" = {
      matchConfig.name = "wgsarah";
      address = [ "10.100.1.1/16" ];
      networkConfig = {
        IPForward = true;
      };
    };
    netdevs."wgsarah" = {
      enable = true;
      netdevConfig = {
        Kind = "wireguard";
        Name = "wgsarah";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets."wgsarah".path;
        ListenPort = 51820;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            AllowedIPs = [
              "10.100.1.2/32"
            ];
            Endpoint = "127.0.0.1:51821";
            PersistentKeepalive = 15;
            PublicKey = builtins.readFile (self + "/secrets/containers/grocy/wireguard.pub");
          };
        }
      ];
    };
    */
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12e0", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12e0", MODE="0666"
  '';

  virtualisation.waydroid.enable = true;
  programs.corectrl.enable = true;

  boot.binfmt.emulatedSystems = [];

  networking = {
    nat = {
      externalInterface = "enp10s0";
    };
    hostName = "sarah";
    hostId = "586769c4";
    firewall = {
      allowedTCPPorts = [ 4747 4748 39595 43751 6567 ];
      allowedUDPPorts = [ 43751 6567 ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/A15D-1FC6";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "age185avxte33jvaexyl5292nczj3drlhc5dnyv8svyyy8u4l0tfgpksz6encl";

  home-manager = {
    backupFileExtension = "bak";
    sharedModules = [
      self.homeManagerModules.desktop
      ({...}:{
        wayland.windowManager.sway = {
          config = {
            workspaceOutputAssign = [
              {
                output = "Dell Inc. DELL P2210 6H6FX214352S";
                workspace = "1";
              }
              {
                output = "ViewSonic Corporation VP2468 Series UN8170400211";
                workspace = "2";
              }
              {
                output = "Dell Inc. DELL P2210 U828K116922M";
                workspace = "3";
              }
              {
                output = "Dell Inc. DELL P2210 0VW5M1C8H57S";
                workspace = "4";
              }
            ];
            output = {
              "Dell Inc. DELL P2210 0VW5M1C8H57S" = {
                transform = "270";
                pos = "1920 -600";
              };
              "ViewSonic Corporation VP2468 Series UN8170400211" = {
                pos = "0 0";
              };
              "Dell Inc. DELL P2210 U828K116922M" = {
                pos = "240 -1050";
              };
              "Dell Inc. DELL P2210 6H6FX214352S" = {
                pos = "-1680 0";
              };
            };
          };
        };
      })
    ];
  };
}
