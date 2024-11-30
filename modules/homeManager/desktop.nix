{
  config,
  pkgs,
  lib,
  ...
}: {
  config = let
    swaylock-bin = "${pkgs.swaylock}/bin/swaylock";
  in {
    home = {
      packages = with pkgs; [
        firefoxpwa
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
        ".mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" = {
          text = ''
            {
              "allowed_extensions": [
                  "keepassxc-browser@keepassxc.org"
              ],
              "description": "KeePassXC integration with native messaging support",
              "name": "org.keepassxc.keepassxc_browser",
              "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
              "type": "stdio"
            }
          '';
        };
      };
      sessionVariables = {
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
      persistence."/persist/home/nina" = {
        directories = [
          ".local/share/godot/app_userdata"
          {
            directory = ".mozilla/firefox/default/bookmarkbackups";
            method = "symlink";
          }
          {
            directory = ".local/share/ruffle/SharedObjects/localhost";
            method = "symlink";
          }
          {
            directory = ".mozilla/firefox/default/storage";
            method = "symlink";
          }
          {
            directory = ".mozilla/firefox/default/extension-store";
            method = "symlink";
          }
          {
            directory = ".mozilla/firefox/default/extension-store-menus";
            method = "symlink";
          }
          {
            directory = ".mozilla/firefox/default/settings";
            method = "symlink";
          }
          ".thunderbird"
          {
            directory = ".local/share/Steam";
            method = "symlink";
          }
          {
            directory = ".local/share/firefoxpwa";
            method = "symlink";
          }
          {
            directory = ".local/share/applications";
            method = "symlink";
          }
          {
            directory = ".local/share/icons/hicolor";
            method = "symlink";
          }
          ".config/vesktop"
          ".config/kdeconnect"
          ".config/jami"
          ".config/godot"
          ".config/keepassxc"
          ".local/share/Jellyfin Media Player"
          ".local/share/jellyfinmediaplayer"
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
          ".config/obsidian/obsidian.json"
          ".config/obsidian/id"
          ".config/obsidian/Perferences"
          ".config/obsidian/Trust Tokens"
          ".config/obsidian/Trust Tokens-journal"
          ".cache/keepassxc/keepassxc.ini"
          ".mozilla/firefox/default/cookies.sqlite"
          ".mozilla/firefox/default/cookies.sqlite-wal"
          ".mozilla/firefox/default/storage.sqlite"
          ".mozilla/firefox/default/storage-sync-v2.sqlite"
          ".mozilla/firefox/default/storage-sync-v2.sqlite-wal"
          ".mozilla/firefox/default/storage-sync-v2.sqlite-shm"
          ".mozilla/firefox/default/content-prefs.sqlite"
          ".mozilla/firefox/default/prefs.js"
        ];
      };
    };
    programs = {
      firefox = {
        enable = true;
        nativeMessagingHosts = [
          pkgs.firefoxpwa
        ];
        profiles = {
          default = {
            extensions = let
              frankerfacez = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon rec {
                addonId = "frankerfacez@frankerfacez.com";
                version = "4.75.7.0";
                pname = "frankerfacez";
                url = "https://addons.mozilla.org/firefox/downloads/file/4383952/${pname}-${version}.xpi";
                sha256 = "sha256-6k4L9aaaWOtUuLBu9FCcoF3y66/BSUGdIVATV1dSZrI=";
                meta = {
                  homepage = "https://www.frankerfacez.com/";
                  description = "The Twitch enhancement suite. Get custom emotes and tons of new features you'll never want to go without.";
                  license = lib.licenses.asl20;
                  mozPermissions = [
                    "https://*.twitch.tv/*"
                    "https://*.frankerfacez.com/*"
                  ];
                  platforms = lib.platforms.all;
                };
              };
            in
              [
                frankerfacez
              ]
              ++ (with pkgs.nur.repos.bandithedoge.firefoxAddons; [
                augmented-steam
                #betterviewer
                #downthemall
                enhanced-github
                indie-wiki-buddy
                lovely-forks
                #pronoundb
                sponsorblock
                #steam-database
                #tridactyl
                ublock-origin
                violentmonkey
              ])
              ++ (with pkgs.nur.repos.ethancedwards8.firefox-addons; [
                enhancer-for-youtube
              ])
              ++ (with pkgs.nur.repos.rycee.firefox-addons; [
                awesome-rss
                #betterttv
                consent-o-matic
                container-tab-groups
                darkreader
                #duckduckgo-privacy-essentials
                #gsconnect
                kagi-search
                keepassxc-browser
                modrinthify
                #mullvad
                multi-account-containers
                private-relay
                pwas-for-firefox
                return-youtube-dislikes
                shinigami-eyes
                #tetrio-plus
              ]);

            settings = {
              "extensions.autoDisableScopes" = 0;
            };
            search = {
              engines = {
                "Kagi" = {
                  urls = [
                    {
                      template = "https://kagi.com/search?q={searchTerms}";
                    }
                  ];
                  iconUpdateURL = "https://assets.kagi.com/v2/favicon-32x32.png";
                  definedAliases = ["@kagi"];
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
        in
          lib.mkOptionDefault {
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
          {command = "mako";}
          {command = "kdeconnect-indicator";}
        ];
      };
    };
    systemd.user.services = {
      swayinhibit = {
        Unit = {
          Description = "Idle Inhibit based on audio";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          Restart = "always";
          Environment = ["PATH=${lib.makeBinPath [pkgs.bash]}"];
          ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
        };
        Install = {
          WantedBy = ["sway-session.target"];
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
          profileNames = ["default"];
        };
      };
    };
  };
}
