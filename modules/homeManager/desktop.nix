{config, pkgs, lib, ...}: {
  config =  let
    swaylock-bin = "${pkgs.swaylock}/bin/swaylock";
  in {
    programs = {
      firefox = {
        enable = true;
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
      syncthing.tray.enable = true;
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
