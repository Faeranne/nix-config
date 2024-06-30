{inputs, config, pkgs, lib, systemConfig, userConfig, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isSway = (builtins.elem "sway" systemConfig.elements);
  isGraphical = isGnome || isKde || isSway;
in {
  config =  let
    swaylock-bin = "${pkgs.swaylock}/bin/swaylock";
  in lib.mkIf isGraphical {
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
      swaylock = {
        enable = true;
      };
      foot = {
        enable = true;
        server.enable = true;
      };
      yazi = {
        enable = true;
        #package = inputs.yazi.packages.${pkgs.system}.default;
        enableZshIntegration = true;
      };
      rofi = {
        enable = true;
        package = pkgs.rofi;
        extraConfig = {
          modes = "window,drun,run,ssh,emoji,calc,file-browser-extended";
          show-icons = true;
        };
        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
          rofi-systemd
          rofi-screenshot
          rofi-power-menu
          rofi-pulse-select
          rofi-file-browser
        ];
        terminal = "${config.programs.foot.package}/bin/foot";
      };
    };
    wayland.windowManager.sway = {
      enable = isSway;
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
    home.packages = with pkgs; [
      jami 
      gimp
      inkscape
      raysession
      jackmix
      lutris
      samba
      swayimg
    ];
    systemd.user.services = {
      swayinhibit = {
        Unit = {
          Description = "Idle Inhibit based on audio";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = ["graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          Restart = "always";
          Environment = [ "PATH=${lib.makeBinPath [ pkgs.bash ]}" ];
          ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";     
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };
    services = {
      swayidle = {
        enable = true;
        systemdTarget = "sway-session.target";
        events = [
          {
            event = "before-sleep";
            command = "${swaylock-bin}";
          }
          {
            event = "lock";
            command = "${swaylock-bin}";
          }
        ];
        timeouts = [
          {
            timeout = 600;
            command = "${swaylock-bin} -fF";
          }
          {
            timeout = 300;
            command = "${pkgs.sway}/bin/swaymsg \"output * power off\"";
            resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * power on\"";
          }
        ];
      };
      gammastep = {
        enable = true;
        tray = true;
        latitude = 39.7;
        longitude = -86.2;
      };
    };
  };
}
