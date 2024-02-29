{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  custom.impermanence.enable = false; 
  disko.devices.disk.disk1 = {
    imageSize = "8G";
    content = {
      type = "gpt";
      partitions.boot = {
        name = "FIRMWARE";
        start = "1M";
        size = "512M";
        content = {
          type = "filesystem";
          format = "fat";
          mountpoint = "/firmware";
        };
      };
    };
  };
  #For whatever reason, getting the nixos-anywhere to work isn't happening
  #, so impermanence isn't gonna work... for now.
}
