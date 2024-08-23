{pkgs, lib, systemConfig, ...}: {
  # Using xdg.portal as my trigger to identify desktop systems, vs server systems
  config = lib.mkIf (builtins.trace true systemConfig.xdg.portal.enable){
    programs = {
      firefox = {
        enable = true;
      };
      thunderbird = {
        enable = true;
        profiles.default = {
          isDefault = true;
        }; };
    };

    services = {
      mako = {
        enable = true;
        output = "ViewSonic Corporation VP2468 Series UN8170400211";
        defaultTimeout = 30000;
      };
      kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
    # TODO: fix monitor layout options.
    wayland.windowManager.sway.config = {
      startup = [
        { command = "vesktop"; }
        { command = "${pkgs.syncthingtray-minimal}/bin/syncthingtray"; }
      ];
    };
    home.packages = with pkgs; [
      obsidian
      discord
      freecad
      keepassxc
      prismlauncher
      godot_4
      ruffle
      aseprite
      #TODO: Fixes nixos/nixpkgs#310227 while waiting for nixos/nixpkgs#310696 to make it to release
      (vesktop.override { withSystemVencord = false; })
      transmission-remote-gtk
      pavucontrol
      ryujinx
    ];
  };
}
