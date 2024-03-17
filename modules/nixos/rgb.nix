{ systemConfig , pkgs, lib, ...}: let
  isRGB = (builtins.elem "rgb" systemConfig.elements);
in {
  services.hardware.openrgb = {
    enable = isRGB;
  };
}
