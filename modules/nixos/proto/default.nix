{ sourceConfig, config, lib, pkgs, modulesPath, ... }:{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.hostPlatform = lib.mkDefault sourceConfig.nixpkgs.hostPlatform;
  networking = {
    hostName = sourceConfig.networking.hostName;
    hostId = sourceConfig.networking.hostId;
  };

  fileSystems = {
    "/boot" = {
      device = sourceConfig.fileSystems."/boot".device;
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  age.rekey.hostPubkey = sourceConfig.age.rekey.hostPubkey;
}
