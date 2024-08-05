{config, pkgs, lib, ...}: {
  imports = [
    ./sway.nix
  ];
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
