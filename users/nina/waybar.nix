{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar.css;
    settings = {
      top_bar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;
        modules-left = [
        ];
        modules-center = [
          "clock#time"
          "custom/separator"
          "clock#week"
          "custom/separator_dot"
          "clock#month"
          "custom/seperator"
          "clock#calendar"
        ];
        modules-right = [
          "network"
          "group/misc"
          "custom/logout_menu"
        ];
        "clock#time" = {
          format = "{:%I:%M %p %Ez}";
        };
        "clock#week" = {
          format = "{:%a}";
        };
        "clock#month" = {
          format = "{:%h}";
        };
        "custom/separator" = {
          format = "|";
        };
        "custom/separator_dot" = {
          format = "•";
        };
        network = {
        };
      };
    };
    systemd.enable = true;
  };
}
