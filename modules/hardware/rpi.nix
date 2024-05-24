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
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
    generic-extlinux-compatible.enable = true;
  };

  zramSwap.enable = true;
  nixpkgs.overlays = [
    (final: prev: {
      ubootNet = final.buildUBoot {
        defconfig = "rpi_4_defconfig";
        extraConfig = ''
          CONFIG_BOOTSTD_FULL=y
          CONFIG_NETCONSOLE=y
          CONFIG_EXTRA_ENV_SETTINGS="serverip=192.168.1.10
          test=4"
        '';
        extraMeta.platforms = ["aarch64-linux"];
        filesToInstall = ["u-boot.bin"];
      };
    }) 
  ];
}
