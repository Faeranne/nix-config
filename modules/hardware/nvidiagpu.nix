{ config, systemConfig, lib, pkgs, ... }: let
  isDesktop = (builtins.elem "gnome" systemConfig.elements) || (builtins.elem "kde" systemConfig.elements);
in {
  #boot.initrd.kernelModules = [ "nvidia" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [
    cudatoolkit
  ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}
