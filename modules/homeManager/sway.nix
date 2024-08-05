{config, lib, pkgs, ...}:{
    wayland.windowManager.sway = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      swaynag.enable = true;
      config = {
        modifier = "Mod4";
        terminal = "foot";
        menu = "${config.programs.rofi.finalPackage}/bin/rofi -show drun";
        bars = [];
        window.commands = [
          {
            command = "floating enable";
            criteria = {
              class = "steam_app_2670630";
            };
          }
        ];
        workspaceLayout = "tabbed";
        workspaceOutputAssign = [
          {
            output = "Dell Inc. DELL P2210 6H6FX214352S";
            workspace = "1";
          }
          {
            output = "ViewSonic Corporation VP2468 Series UN8170400211";
            workspace = "2";
          }
          {
            output = "Dell Inc. DELL P2210 U828K116922M";
            workspace = "3";
          }
          {
            output = "Dell Inc. DELL P2210 0VW5M1C8H57S";
            workspace = "4";
          }
        ];
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
          menu = config.wayland.windowManager.sway.config.menu;
          swaylock-bin = "${pkgs.swaylock}/bin/swaylock";
        in lib.mkOptionDefault {
          "${modifier}+g" = "exec TIMESTAMP=$(date +\"%Y%m%d%H%M\") grim /tmp/screenshot$TIMESTAMP.png && gimp /tmp/screenshot$TIMESTAMP.png && rm /tmp/screenshot$TIMESTAMP.png";
          "${modifier}+Mod1+l" = "exec ${swaylock-bin} -fF";
          "${modifier}+space" = "exec ${menu}";
        };
        input = {
          "*" = {
            xkb_layout = "us";
            xkb_options = "caps:escape";
            xkb_numlock = "enabled";
          };
        };
        startup = [
          { command = "mako"; }
          { command = "kdeconnect-indicator"; }
        ];
      };
    };
  }
