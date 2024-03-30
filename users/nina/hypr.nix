{pkgs, ...}: { 
  wayland.windowManager.hyprland = {
    settings = {
      input = {
        kb_layout = "us";
        follow_mouse = "1";
        kb_options = "caps:escape";
      };
      decoration = {
        "col.shadow" = "0xff8bd5ca";
        "col.shadow_inactive" = "0xff24273a";
        rounding = "10";
        blur = {
          size = "8";
          passes = "2";
        };
        drop_shadow = "yes";
        shadow_range = "15";
        shadow_offset = "0, 0";
        shadow_render_power = "3";
        active_opacity = "1.0";
        inactive_opacity = "0.7";
        fullscreen_opacity = "1.0";
      };
      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 2, myBezier"
          "windowsOut, 1, 2, default, popin 80%"
          "border, 1, 3, default"
          "fade, 1, 2, default"
          "workspaces, 1, 1, default"
        ];
      };
      "$mod" = "SUPER";
      monitor = [
        "desc:ViewSonic Corporation VP2468 Series UN8170400211, 1680x1050, 0x0, 1"
        "desc:Dell Inc. DELL P2210 6H6FX214352S, 1680x1050, -1680x-525, 1"
        "desc:Dell Inc. DELL P2210 U828K116922M, 1680x1050, 0x-1050, 1"
        "desc:Dell Inc. DELL P2210 0VW5M1C8H57S, 1680x1050, 1680x-630, 1, transform, 1"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      bind = [
        "$mod, T, exec, ${pkgs.kitty}/bin/kitty"
        "$mod, B, exec, ${pkgs.firefox}/bin/firefox"
        "$mod, F, exec, ${pkgs.xfce.thunar}/bin/thunar"
        "$mod, D, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun"
        "$mod CTRL, F, togglefloating,"
      ];
    };
  };
}
