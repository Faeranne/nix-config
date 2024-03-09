{ config, systemConfig, lib, pkgs, ... }: let
  isDesktop = (builtins.elem "gnome" systemConfig.elements) || (builtins.elem "kde" systemConfig.elements);
in {
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
  hardware.opengl = lib.mkIf isDesktop {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    #extraPackages = with pkgs; lib.mkIf (builtins.elem "amdgpu" systemConfig.elements) [ amdvlk ];
    #extraPackages32 = with pkgs; lib.mkIf (builtins.elem "amdgpu" systemConfig.elements) [ driversi686Linux.amdvlk ];
  };
}
