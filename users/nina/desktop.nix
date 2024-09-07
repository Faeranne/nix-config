{pkgs, lib, systemConfig, ...}: {
  # Using xdg.portal as my trigger to identify desktop systems, vs server systems
  config = lib.mkIf systemConfig.xdg.portal.enable{
    programs = {
      firefox = {
        profiles.default = {
          containers = {
            personal = {
              color = "orange";
              icon = "fingerprint";
              id = 1;
              name = "Personal";
            };
            google = {
              color = "red";
              icon = "circle";
              id = 2;
              name = "Youtube";
            };
            finance = {
              color = "green";
              icon = "dollar";
              id = 3;
              name = "Finance";
            };
            homelab = {
              color = "red";
              icon = "fingerprint";
              id = 4;
              name = "Homelab";
            };
          };
          containersForce = true;
        };
      };
      thunderbird = {
        enable = true;
        profiles.default = {
          isDefault = true;
        };
      };
    };

    systemd.user.targets = {
      "tray" = {
        Unit = {
          After = [
            "sway-session.target"
          ];
        };
      };
    };
    services = {
      syncthing.tray.enable =true;
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
      ];
    };
    home = {
      persistence."/persist/home/nina" = {
        directories = [
          {
            directory = ".local/share/PrismLauncher";
            method = "symlink";
          }
        ];
      };
      packages = with pkgs; [
        obsidian
        discord
        freecad
        keepassxc
        prismlauncher
        godot_4
        ruffle
        aseprite
        qimgv
        #TODO: Fixes nixos/nixpkgs#310227 while waiting for nixos/nixpkgs#310696 to make it to release
        (vesktop.override { withSystemVencord = false; })
        transmission-remote-gtk
        pavucontrol
        ryujinx
      ];
    };
  };
}
