{config, pkgs, lib, systemConfig, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isSway = (builtins.elem "sway" systemConfig.elements);
  isGraphical = isGnome || isKde || isSway;
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
    services = {
      mako = {
        enable = true;
        output = "ViewSonic Corporation VP2468 Series UN8170400211";
        defaultTimeout = 30000;
      };
      kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
    wayland.windowManager.sway.config = {
      assigns = {
        "4" = [
          {app_id = "vesktop";}
        ];
      };
      output = {
        "*" = {
        };
      };
      startup = [
        { command = "vesktop"; }
      ];
    };
    home.packages = with pkgs; [
      obsidian
      discord
      freecad
      prismlauncher
      godot_4
      ruffle
      aseprite
      #TODO: Fixes nixos/nixpkgs#310227 while waiting for nixos/nixpkgs#310696 to make it to release
      (vesktop.override { withSystemVencord = false; })
      transmission-remote-gtk
      pavucontrol
      ryujinx
    ];
  };
}
