{ config, lib, pkgs, ... }:
let 
  cfg = config.custom.desktop;
in
{
  options.custom.desktop = {
  };
  config = lib.mkIf (builtins.elem "desktop" config.custom.elements) {
    services = {
      udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
      xserver = {
        enable = true;
        displayManager = {
          sddm = {
            enable = (builtins.elem "kde" config.custom.elements);
            wayland.enable = true;
          };
          gdm = {
            enable = (builtins.elem "gnome" config.custom.elements);
            wayland = true;
          };
        };
        desktopManager = {
          plasma5.enable = (builtins.elem "kde" config.custom.elements);
          gnome.enable = (builtins.elem "gnome" config.custom.elements);
        };
        xkb.layout = "us";
        xkbOptions = "caps:escape";
        excludePackages = with pkgs; [ xterm ];
      };
    };
    programs = {
      firefox = {
        enable = true;
      };
    };
  };
}
