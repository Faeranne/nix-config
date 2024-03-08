{config, pkgs, lib, systemConfig, ...}:
{
  config = lib.mkIf (builtins.elem "desktop" systemConfig.elements) {
    dconf = lib.mkIf (builtins.elem "gnome" systemConfig.elements) {
      enable = true;
      settings = {
        "org/gnome/desktop/wm/preferences".button-layout = "minimize,maximize,close";
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "gsconnect@andyholmes.github.io"
          ];
          favorite-apps = [
            "firefox.desktop"
            "discord.desktop"
            "org.gnome.Console.desktop"
            "obsidian.desktop"
            "org.gnome.Nautilus.desktop"
          ];
        };
        "org/gnome/desktop/background" = {
         picture-uri = ("file://" + ../resources/background.png);
         picture-uri-dark = ("file://" + ../resources/background.png);
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
        };
        "org/gnome/desktop/wm/preferences" = {
          workspaces-names = [
            "Main"
          ];
        };
        "org/gnome/mutter" = {
          edge-tiling = true;
          dynamic-workspaces = true;
          workspaces-only-on-primary = true;
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-automatic = true;
          night-light-temperature = 3700;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-type = "suspend";
          power-button-action = "interactive";
          sleep-inactive-battery-timeout = 1800;
        };
        "org/gnome/desktop/session" = {
          idle-delay = 900;
        };
      };
    };
  };
}
