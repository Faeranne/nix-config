{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (builtins.elem "desktop" config.custom.elements) {
    boot.initrd.kernelModules = lib.mkIf (builtins.elem "amdgpu" config.custom.elements) [ "amdgpu" ];
    services.xserver.videoDrivers = lib.mkIf (builtins.elem "amdgpu" config.custom.elements) [ "amdgpu" ];
    systemd.tmpfiles.rules = lib.mkIf (builtins.elem "amdgpu" config.custom.elements) [
      "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
    ];
    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; lib.mkIf (builtins.elem "amdgpu" config.custom.elements) [ amdvlk ];
      extraPackages32 = with pkgs; lib.mkIf (builtins.elem "amdgpu" config.custom.elements) [ driversi686Linux.amdvlk ];
    };
  };
}
