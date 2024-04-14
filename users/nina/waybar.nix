{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar.css;
    settings = {
      top_bar = {
        layer = "top";
        position = "top";
        height = 30;
        margin = "0 0 0 0";
        modules-left = [
          "sway/workspaces"
          "tray"
          "sway/mode"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "backlight"
          "pulseaudio"
          "temperature"
          "memory"
          "network"
        ];
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1"= "";
            "2"= "";
            "3"= "";
            "4"= "";
            "5"= "";
            "6"= "";
            "7"= "";
            "8"= "";
            "9"= "";
            "10"= "";
          };
        };
      };
    };
    systemd.enable = true;
  };
}
