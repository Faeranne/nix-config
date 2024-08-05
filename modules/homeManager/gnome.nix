{lib, ...}:{
    dconf = {
      enable = true;
      settings = {
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
  }
