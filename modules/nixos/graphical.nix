{ systemConfig , pkgs, lib, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isSway = (builtins.elem "sway" systemConfig.elements);
  isGraphical = isGnome || isKde || isSway;
  isX11 = isGnome || isKde;
in {
  xdg.portal = lib.mkIf isGraphical {
    config = {
      common = {
        default = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.Screencast" = [
          "wlr"
        ];
        "org.freedesktop.impl.portal.Screenshot" = [
          "wlr"
        ];
      };
    };
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
  services = {
    udev.packages = with pkgs; lib.mkIf isGnome [ gnome.gnome-settings-daemon ];
    dbus.enable = lib.mkDefault isGraphical;
    gvfs = {
      package = pkgs.gvfs;
      enable = isGraphical;
    };
    tumbler.enable = true;
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
    displayManager = {
      sddm = {
        enable = isKde && (! isGnome);
      };
    };
    xserver = {
      enable = false;
      displayManager = {
        gdm = {
          enable = isGnome;
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
      enable = isGraphical;
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
    thunar = lib.mkIf isSway {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman thunar-media-tags-plugin ];
    };
    file-roller = lib.mkIf isSway {
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
      wofi
    ]) else []) ++ 
    (if isSway then (with pkgs; [
      grim 
      sway-contrib.grimshot
      swappy
      wl-clipboard
      f3d
    ]) else [] ) ++
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
