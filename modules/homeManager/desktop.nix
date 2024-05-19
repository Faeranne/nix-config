{config, pkgs, lib, systemConfig, userConfig, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isSway = (builtins.elem "sway" systemConfig.elements);
  isGraphical = isGnome || isKde || isSway;
in {
  config = lib.mkIf isGraphical {
    dconf = lib.mkIf isGnome {
      enable = true;
      settings = {
        "org/gnome/desktop/background" = {
         picture-uri = ("file://" + userConfig.wallpaper);
         picture-uri-dark = ("file://" + (if userConfig ? darkWallpaper then userConfig.darkWallpaper else userConfig.wallpaper));
        };
        "org/gnome/desktop/session" = lib.mkDefault {
          idle-delay = 900;
        };
        "org/gnome/settings-daemon/plugins/color" = lib.mkDefault {
          night-light-enabled = true;
          night-light-schedule-automatic = true;
          night-light-temperature = 3700;
        };
        "org/gnome/settings-daemon/plugins/power" = lib.mkDefault {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-type = "suspend";
          power-button-action = "interactive";
          sleep-inactive-battery-timeout = 1800;
        };
        "org/gnome/mutter" = lib.mkDefault {
          edge-tiling = true;
          dynamic-workspaces = true;
          workspaces-only-on-primary = true;
        };
      };
    };
    programs = {
      firefox = {
        enable = isGraphical;
        nativeMessagingHosts = with pkgs; (if isGnome then [ gnome-browser-connector ] else []);
      };
    };
    wayland.windowManager.sway = {
      enable = isSway;
      systemd.enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      config = {
        modifier = "Mod4";
        terminal = "kitty";
        menu = "${pkgs.rofi}/bin/rofi -show drun -theme theme.rasi | ${pkgs.findutils}/bin/xargs swaymsg exec --";
        output = {
          "Dell Inc. DELL P2210 0VW5M1C8H57S" = {
            transform = "270";
            pos = "1920 -600";
          };
          "ViewSonic Corporation VP2468 Series UN8170400211" = {
            pos = "0 0";
          };
          "Dell Inc. DELL P2210 U828K116922M" = {
            pos = "240 -1050";
          };
          "Dell Inc. DELL P2210 6H6FX214352S" = {
            pos = "-1680 0";
          };
        };
        keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+g" = "exec TIMESTAMP=$(date +\"%Y%m%d%H%M\") grim /tmp/screenshot$TIMESTAMP.png && gimp /tmp/screenshot$TIMESTAMP.png && rm /tmp/screenshot$TIMESTAMP.png";
        };
        input = {
          "*" = {
            xkb_layout = "us";
            xkb_options = "caps:escape";
          };
        };
        startup = [
          { command = "mako"; }
        ];
      };
    };
    home.packages = with pkgs; [
      jami 
      gimp
      inkscape
      raysession
      jackmix
      lutris
      samba
    ];
  };
}
