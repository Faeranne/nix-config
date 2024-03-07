{ config, lib, pkgs, nixpkgs, ... }:
let 
  cfg = config.custom.desktop;
in
{
  options.custom.desktop = {
  };
  config = lib.mkIf (builtins.elem "desktop" config.custom.elements) {
    services = {
      udev.packages = with pkgs; [ gnome.gnome-settings-daemon yubikey-personalization ];
      pcscd.enable = true;
      xserver = {
        enable = true;
        displayManager = {
          sddm = {
            enable = (builtins.elem "kde" config.custom.elements);
            wayland.enable = true;
          };
          gdm = {
            enable = (builtins.elem "gnome" config.custom.elements);
            wayland = true;
          };
        };
        desktopManager = {
          plasma5.enable = (builtins.elem "kde" config.custom.elements);
          gnome.enable = (builtins.elem "gnome" config.custom.elements);
        };
        xkb.layout = "us";
        xkb.options = "caps:escape";
        excludePackages = with pkgs; [ xterm ];
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        socketActivation = true;
        extraConfig.pipewire."91-null-sinks" = {
          context.objects = [
            {
              # A default dummy driver. This handles nodes marked with the "node.always-driver"
              # properyty when no other driver is currently active. JACK clients need this.
              factory = "spa-node-factory";
              args = {
                factory.name     = "support.node.driver";
                node.name        = "Dummy-Driver";
                priority.driver  = 8000;
              };
            }
            {
              factory = "adapter";
              args = {
                factory.name     = "support.null-audio-sink";
                node.name        = "Microphone-Proxy";
                node.description = "Microphone";
                media.class      = "Audio/Source/Virtual";
                audio.position   = "MONO";
              };
            }
            {
              factory = "adapter";
              args = {
                factory.name     = "support.null-audio-sink";
                node.name        = "Main-Output-Proxy";
                node.description = "Main Output";
                media.class      = "Audio/Sink";
                audio.position   = "FL,FR";
              };
            }
            {
              factory = "adapter";
              args = {
                factory.name     = "support.null-audio-sink";
                node.name        = "Game-Proxy";
                node.description = "Game Audio Output";
                media.class      = "Audio/Sink";
                audio.position   = "FL,FR";
              };
            }
            {
              factory = "adapter";
              args = {
                factory.name     = "support.null-audio-sink";
                node.name        = "Media-Proxy";
                node.description = "Media Audio Output";
                media.class      = "Audio/Sink";
                audio.position   = "FL,FR";
              };
            }
            {
              factory = "adapter";
              args = {
                factory.name     = "support.null-audio-sink";
                node.name        = "Chat-Proxy";
                node.description = "Chat Audio Output";
                media.class      = "Audio/Sink";
                audio.position   = "FL,FR";
              };
            }
          ];
        };
      };
      gnome.gnome-browser-connector.enable = true;
    };
    hardware.pulseaudio.enable = false;
    programs = {
      firefox = {
        enable = true;
        nativeMessagingHosts = {
          packages = with pkgs; [
            browserpass
          ];
        };
      };
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
      dconf.enable = true;
    };
    nixpkgs.config.firefox.enableGnomeExtensions = true;
    environment = {
      systemPackages = with pkgs; [
        discord
        raysession
        kitty
        passage
        obsidian
        helvum
        qpwgraph
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
      ];
      gnome.excludePackages = (with pkgs; [
        gnome-photos
        gnome-tour
      ]) ++ (with pkgs.gnome; [
        cheese
        gnome-music
        epiphany
        geary
        gnome-initial-setup
        gnome-contacts
      ]);
    };
    home-manager.users.nina.dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/wm/preferences".button-layout = "minimize,maximize,close";
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "gsconnect@andyholmes.github.io"
          ];
          favorite-apps = [
            "firefox.desktop"
            "discord.desktop"
            "org.gnome.Console.desktop"
            "obsidian.desktop"
            "org.gnome.Nautilus.desktop"
          ];
        };
        "org/gnome/desktop/background" = {
         picture-uri = ("file://" + ../resources/background.png);
         picture-uri-dark = ("file://" + ../resources/background.png);
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
        };
        "org/gnome/desktop/wm/preferences" = {
          workspaces-names = [
            "Main"
          ];
        };
        "org/gnome/mutter" = {
          edge-tiling = true;
          dynamic-workspaces = true;
          workspaces-only-on-primary = true;
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-automatic = true;
          night-light-temperature = 3700;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-type = "suspend";
          power-button-action = "interactive";
          sleep-inactive-battery-timeout = 1800;
        };
        "org/gnome/desktop/session" = {
          idle-delay = 900;
        };
      };
    };
    system.activationScripts.setNinaIcon.text = ("cp " + ../resources/avatar.png + " /var/lib/AccountsService/icons/nina");
  };
}
