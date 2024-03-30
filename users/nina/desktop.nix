{config, pkgs, lib, systemConfig, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isGraphical = isGnome || isKde;
in {
  config = lib.mkIf isGraphical {
    dconf = lib.mkIf isGnome {
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "gsconnect@andyholmes.github.io"
          ];
          favorite-apps = [
            "firefox.desktop"
            "vesktop.desktop"
            "org.gnome.Console.desktop"
            "obsidian.desktop"
            "thunderbird.desktop"
            "org.gnome.Nautilus.desktop"
          ];
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
        };
        "org/gnome/desktop/wm/preferences" = {
          button-layout = "minimize,maximize,close";
          workspaces-names = [
            "Main"
          ];
        };
      };
    };
    programs = {
      firefox = {
        enable = true;
      };
      thunderbird = {
        enable = true;
        profiles.default = {
          isDefault = true;
        };
      };
    };
    home.packages = with pkgs; [
      obsidian
      discord
      freecad
      prismlauncher
      godot_4
      vesktop
      transmission-remote-gtk
      xfce.thunar
      pavucontrol
      rofi-wayland
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
    };
  };
}
