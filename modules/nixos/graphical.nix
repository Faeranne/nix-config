{ systemConfig , pkgs, lib, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isGraphical = isGnome || isKde;
in {
  xdg.portal = lib.mkIf isGraphical {
    enable = true;
    wlr.enable = true;
  };
  services = {
    udev.packages = with pkgs; lib.mkIf isGnome [ gnome.gnome-settings-daemon ];
    dbus.enable = lib.mkDefault isGraphical;
    xserver = {
      enable = isGraphical;
      displayManager = {
        sddm = {
          enable = isKde && (! isGnome);
          wayland.enable = true;
        };
        gdm = {
          enable = isGnome;
          wayland = true;
        };
      };
      desktopManager = {
        plasma5.enable = isKde;
        gnome.enable = isGnome;
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
    gnome.gnome-browser-connector.enable = isGnome;
  };
  programs = {
    ssh.askPassword = lib.mkIf isGraphical "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";
    kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };
  hardware.pulseaudio.enable = false;
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = (if isGraphical then (with pkgs; [
      helvum
      qpwgraph
      ruffle
      swww
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xwayland
      nerdfonts
      meslo-lgs-nf
      rofi-wayland
      wofi
    ]) else []) ++ 
    (if isGnome then (with pkgs; [
      gnomeExtensions.appindicator
      gnome.gnome-tweaks
    ]) else [] );
    gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ ( with pkgs.gnome; [
      cheese
      gnome-music
      epiphany
      geary
      gnome-initial-setup
      gnome-contacts
    ]);
  };
}
