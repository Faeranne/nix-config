{ config, lib, pkgs, nixpkgs, systemConfig, ... }:
let 
  gnomeEnabled = builtins.elem "gnome" systemConfig.elements;
  kdeEnabled = builtins.elem "kde" systemConfig.elements;
  desktopEnabled = gnomeEnabled || kdeEnabled;
in
{
  options.custom.desktop = {
  };
  config = lib.mkIf desktopEnabled {
    services = {
      udev.packages = with pkgs; [ yubikey-personalization ] lib.mkIf gnomeEnabled [ gnome.gnome-settings-daemon ];
      xserver = {
        enable = true;
        displayManager = {
          sddm = {
            enable = (builtins.elem "kde" config.custom.elements);
            wayland.enable = true;
          };
          gdm = {
            enable = gnomeEnabled;
            wayland = true;
          };
        };
        desktopManager = {
          plasma5.enable = (builtins.elem "kde" config.custom.elements);
          gnome.enable = gnomeEnabled;
        };
        xkb.layout = "us";
        xkb.options = "caps:escape";
        excludePackages = with pkgs; [ xterm ];
      };
      pipewire = {
        enable = true;
        audio.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };
    } // lib.mkIf gnomeEnabled { gnome.gnome-browser-connector.enable = true };
    hardware.pulseaudio.enable = false;
    programs = {
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
      dconf.enable = true;
      nix-ld = {
        enable = true;
      };
    };
    nixpkgs.config.firefox.enableGnomeExtensions = true;
    environment = {
      systemPackages = with pkgs; [
        discord
        kitty
        passage
        obsidian
        helvum
        qpwgraph
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
        jackmix
        pipewire.jack
        ruffle
        appimagekit
        appimage-run
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
    system.activationScripts.setNinaIcon.text = ("cp " + ../resources/avatar.png + " /var/lib/AccountsService/icons/nina");
  };
}
