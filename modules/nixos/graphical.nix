{ systemConfig , pkgs, lib, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isSway = (builtins.elem "sway" systemConfig.elements);
  isGraphical = isGnome || isKde || isSway;
  isX11 = isGnome || isKde;
in {
  xdg.portal = lib.mkIf isGraphical {
    enable = true;
    wlr.enable = true;
  };
  services = {
    udev.packages = with pkgs; lib.mkIf isGnome [ gnome.gnome-settings-daemon ];
    dbus.enable = lib.mkDefault isGraphical;
    greetd = {
      enable = true;
      vt = 7;
      settings = {
        default_session.command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --cmd sway
        '';
      };
    };
    xserver = {
      enable = false;
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
    };
  };
  hardware.pulseaudio.enable = false;
  hardware.opengl.enable = true;
  environment = {
    etc = {
      "greetd/environments".text = ''
        sway
        dbus-run-session -- gnome-shell --display-server --wayland
      '';
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = (if isGraphical then (with pkgs; [
      helvum
      qpwgraph
      ruffle
      swww
      xdg-desktop-portal-gtk
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
