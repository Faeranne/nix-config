{systemConfig, pkgs, lib, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isDesktop = isGnome || isKde;
in {
}
