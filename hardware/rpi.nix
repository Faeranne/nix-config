{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  #custom.impermanence.enable = false; 
  # We rely on Tow-boot to ensure a uniform platform
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
    generic-extlinux-compatible.enable = false;
  };

  #default the root disk to the lower usb3 storage device. this helps normalize how things are layed out.
  #NOTE: Be aware that a slow usb device can cause havoc.  Use a high-quality usb drive!
  custom = {
    defaultDisk = {
      rootDisk = "/dev/disk/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usbv3-0:2:1.0-scsi-0:0:0:0";
      zfsPartition = "/dev/disk/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usbv3-0:2:1.0-scsi-0:0:0:0-part2";
    };
  };
}
