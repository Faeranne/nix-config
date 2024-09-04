{self, config, myLib, ...}: let
  mkPeer = myLib.mkPeer "sarah";
in{
  imports = with self.nixosModules; [
    base 
    emulation
    gaming
    desktop
    services.clamav
    services.printers
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

  topology.self = {
    name = "Sarah";
    hardware = {
      info = "Desktop Computer";
    }; primaryNetwork = "home";
    primaryInterface = "enp10s0";
    interfaces.enp10s0 = {
      addresses = ["192.168.1.80"];
      network = "home";
      physicalConnections = [
        (config.lib.topology.mkConnection "switch2" "eth2")
      ];
    };
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
    wireguard.interfaces = {
      wgsarah = {
        ips = ["10.100.2.2/32"];
        privateKeyFile = config.age.secrets.wgsarah.path;
        listenPort = 52820;
        peers = [
        ];
      };
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
      ({...}:{
        home.file.".local/state/wireplumber/default-routes".text = ''
          [default-routes]
          alsa_card.usb-SteelSeries_Arctis_Nova_Pro_Wireless-00:output:analog-output={"mute":false, "channelMap":["FL", "FR"], "channelVolumes":[1.000000, 1.000000], "latencyOffsetNsec":0}
          alsa_card.usb-SteelSeries_Arctis_Nova_Pro_Wireless-00:profile:output:analog-stereo+input:mono-fallback=["analog-output"]
        '';
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
