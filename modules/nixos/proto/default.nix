{ sourceConfig, config, lib, pkgs, modulesPath, ... }:{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      #./user.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = lib.mkDefault "8425e349"; #use the nixos iso hostId for compatibility
    hostName = "proto";
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/EFI";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };
}
