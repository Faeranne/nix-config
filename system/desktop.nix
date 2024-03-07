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
        };
        "org/gnome/desktop/background" = {
         # picture-uri = "file:///home/nina/.local/share/backgrounds/2024-03-07-05-42-22-nexus_labs_v3.png";
         # picture-uri-dark = "file:///home/nina/.local/share/backgrounds/2024-03-07-05-42-22-nexus_labs_v3.png";
        };
      };
    };
  };
}
