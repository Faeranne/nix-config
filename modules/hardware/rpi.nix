{ config, lib, pkgs, modulesPath, inputs, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # We rely on Tow-boot to ensure a uniform platform
  boot.loader = {
    systemd-boot.enable = lib.mkOverride 110 true;
    efi.canTouchEfiVariables = lib.mkOverride 110 false;
    generic-extlinux-compatible.enable = lib.mkOverride 110 false;
  };

  zramSwap.enable = true;
}
