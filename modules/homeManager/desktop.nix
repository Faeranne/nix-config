{config, pkgs, lib, ...}: {
  config =  let
    swaylock-bin = "${pkgs.swaylock}/bin/swaylock";
  in {
    home = {
      file = {
        ".mozilla/native-messaging-hosts/de.kkapsner.keepassxc_mail.json" = {
          text = ''
            {
              "allowed_extensions": [
                  "keepassxc-mail@kkapsner.de"
              ],
              "description": "KeePassXC integration with native messaging support",
              "name": "de.kkapsner.keepassxc_mail",
              "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
              "type": "stdio"
            }
          '';
        };
      };
      persistence."/persist/home/nina" = {
        directories = [
          ".mozilla"
          ".thunderbird"
          {
            directory = ".local/share/Steam";
            method = "symlink";
          }
          ".config/vesktop"
          ".config/kdeconnect"
          ".config/jami"
          ".config/godot"
          ".config/keepassxc"
          {
            directory = "Desktop";
            method = "symlink";
          }
          {
            directory = "Documents";
            method = "symlink";
          }
          {
            directory = "Downloads";
            method = "symlink";
          }
          {
            directory = "Games";
            method = "symlink";
          }
          {
            directory = "Music";
            method = "symlink";
          }
          {
            directory = "My Games";
            method = "symlink";
          }
          {
            directory = "Pictures";
            method = "symlink";
          }
          {
            directory = "Videos";
            method = "symlink";
          }
        ];
        files = [
        ];
      };
    };
    programs = {
      firefox = {
        enable = true;
        profiles = {
          default = {
            extensions = (with pkgs.nur.repos.bandithedoge.firefoxAddons; [
              augmented-steam
              betterviewer
              downthemall
              enhanced-github
              indie-wiki-buddy
              lovely-forks
              pronoundb
              sponsorblock
              steam-database
              tridactyl
              ublock-origin
              violentmonkey
            ]) ++ (with pkgs.nur.repos.ethancedwards8.firefox-addons; [
              enhancer-for-youtube
            ]) ++ (with pkgs.nur.repos.rycee.firefox-addons; [
              awesome-rss
              betterttv
              consent-o-matic
              container-tab-groups
              darkreader
              duckduckgo-privacy-essentials
              gsconnect
              kagi-search
              keepassxc-browser
              modrinthify
              mullvad
              multi-account-containers
              private-relay
              return-youtube-dislikes
              shinigami-eyes
              tetrio-plus
            ]);

            settings = {
              "extensions.autoDisableScopes" = 0;
            };
            search = {
              engines = {
                "Kagi" = {
                  urls = [{
                    template = "https://kagi.com/search?q={searchTerms}";
                  }];
                  iconUpdateURL = "https://assets.kagi.com/v2/favicon-32x32.png";
                  definedAliases = [ "@kagi" ];
                };
              };
              force = true;
              default = "Kagi";
            };
          };
        };
      };
      swaylock = {
        enable = true;
      };
      foot = {
        enable = true;
        server.enable = true;
      };
      yazi = {
        enable = true;
        enableZshIntegration = true;
      };
      rofi = {
        enable = true;
        package = pkgs.rofi;
        extraConfig = {
          modes = "window,drun,run,ssh,emoji,calc,file-browser-extended";
          show-icons = true;
        };
        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
          rofi-systemd
          rofi-screenshot
          rofi-power-menu
          rofi-pulse-select
          rofi-file-browser
        ];
        terminal = "${config.programs.foot.package}/bin/foot";
      };
    };
    home = {
      packages = with pkgs; [
        jami 
        gimp
        inkscape
        raysession
        jackmix
        lutris
        samba
        swayimg
        keepassxc
      ];
    };
    wayland.windowManager.sway = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      swaynag.enable = true;
      config = {
        modifier = "Mod4";
        terminal = "foot";
        menu = "${config.programs.rofi.finalPackage}/bin/rofi -show drun";
        bars = [];
        window.commands = [
          {
            command = "floating enable";
            criteria = {
              class = "steam_app_2670630";
            };
          }
        ];
        workspaceLayout = "tabbed";
        keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
          menu = config.wayland.windowManager.sway.config.menu;
          swaylock-bin = "${pkgs.swaylock}/bin/swaylock";
        in lib.mkOptionDefault {
          "${modifier}+g" = "exec TIMESTAMP=$(date +\"%Y%m%d%H%M\") grim /tmp/screenshot$TIMESTAMP.png && gimp /tmp/screenshot$TIMESTAMP.png && rm /tmp/screenshot$TIMESTAMP.png";
          "${modifier}+Mod1+f" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.qrscan}/bin/qrscan - | sed -nr 's/.*secret=([[a-zA-Z0-9]*)&.*/\\1/p' | ${pkgs.wl-clipboard}/bin/wl-copy";
          "${modifier}+Mod1+l" = "exec ${swaylock-bin} -fF";
          "${modifier}+space" = "exec ${menu}";
        };
        input = {
          "*" = {
            xkb_layout = "us";
            xkb_options = "caps:escape";
            xkb_numlock = "enabled";
          };
        };
        startup = [
          { command = "mako"; }
          { command = "kdeconnect-indicator"; }
        ];
      };
    };
    systemd.user.services = {
      swayinhibit = {
        Unit = {
          Description = "Idle Inhibit based on audio";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = ["graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          Restart = "always";
          Environment = [ "PATH=${lib.makeBinPath [ pkgs.bash ]}" ];
          ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";     
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };
    services = {
      swayidle = {
        enable = true;
        systemdTarget = "sway-session.target";
        events = [
          {
            event = "before-sleep";
            command = "${swaylock-bin}";
          }
          {
            event = "lock";
            command = "${swaylock-bin}";
          }
        ];
        timeouts = [
          {
            timeout = 600;
            command = "${swaylock-bin} -fF";
          }
          {
            timeout = 300;
            command = "${pkgs.sway}/bin/swaymsg \"output * power off\"";
            resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * power on\"";
          }
        ];
      };
      gammastep = {
        enable = true;
        tray = true;
        latitude = 39.7;
        longitude = -86.2;
      };
    };
    stylix = {
      targets = {
        swaylock.enable = true;
        sway.enable = true;
        vesktop.enable = false;
        foot.enable = true;
        gtk.enable = true;
        waybar.enable = true;
        firefox = {
          enable = true;
          profileNames = [ "default" ];
        };
      };
    };
  };
}
