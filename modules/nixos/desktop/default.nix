{self, config, pkgs, lib, ...}:{
  virtualisation.vmVariant = {
    virtualisation = {
      graphics = lib.mkForce true;
    };
  };
  boot = {
    plymouth = {
      enable = true;
    };
  };
  xdg.portal = {
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
    flatpak.enable = true;
    dbus.enable = true;
    gvfs = {
      package = pkgs.gvfs;
      enable = true;
    };
    tumbler.enable = true;
    greetd = let
      swayConfig = pkgs.writeText "greetd-sway-config" ''
        exec "${config.programs.regreet.package}/bin/regreet; swaymsg exit;
        bindsym Mod4+shift+e exec swaynag \
          -t warning \
          -m 'What do you want to do?' \
          -b 'Poweroff' 'systemctl poweroff' \
          -b 'Reboot' 'systemctl reboot'
      '';
    in {
      enable = true;
      vt = 7;
      #settings.default_session.command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
      settings.default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd sway
      '';
    };
    pipewire = {
      enable = true;
      audio.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };

  programs = {
    ssh.askPassword = "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";
    kdeconnect.enable = true;
    adb = {
      enable = true;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };
    file-roller.enable = true;
    regreet.enable = true;
  };

  hardware = {
    pulseaudio.enable = false;
    opengl.enable = true;
  };

  fonts.packages = with pkgs; [
    nerdfonts
  ];

  environment = {
    etc = {
      "greetd/environments".text = ''
        sway
        ${pkgs.zsh}/bin/zsh
        steam-gamescope
      '';
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      helvum
      qpwgraph
      ruffle
      swww
      xdg-desktop-portal-gtk
      xwayland
      nerdfonts
      meslo-lgs-nf
      wofi
      kicad
      mpv
      grim
      sway-contrib.grimshot
      swappy
      wl-clipboard
      f3d
    ];
  };
  home-manager = {
    sharedModules = [
      self.homeModules.desktop
    ];
  };
}
