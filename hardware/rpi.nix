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

  # We rely on Tow-boot to ensure a uniform platform
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
    generic-extlinux-compatible.enable = false;
  };
}
