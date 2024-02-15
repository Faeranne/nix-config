{ config, lib, pkgs, ... }:
let
  cfg = config.custom.homepage;
  inherit (lib) mkOption types;

in
{
  options.custom.homepage = {
    enable = mkOption {
      default = false;
      description = "Enable homepage module";
      type = types.bool;
    };
    local = mkOption {
      description = "Container IP address.";
      type = types.str;
    };
    url = mkOption {
      description = "Url for homepage.";
      type = types.str;
    };
    settings = {
      title = mkOption {
        default = "Homepage";
        description = "Text for the titlebar.";
        type = types.str;
      };
      startUrl = mkOption {
        default = "/";
        description = "Base url for apps.";
        type = types.str;
      };
      background = {
        image = mkOption {
          description = "Background image.";
          type = types.str;
        };
        blur = mkOption {
          description = "Background image blur.";
          type = types.str;
        };
        saturate = mkOption {
          description = "Background image saturate.";
          type = types.str;
        };
        brightness = mkOption {
          description = "Background image brightness.";
          type = types.str;
        };
        opacity = mkOption {
          description = "Background image opacity.";
          type = types.str;
        };
      };
      cardBlur = mkOption {
        description = "Background image blur for cards.";
        type = types.str;
      };
      favicon = mkOption {
        description = "Change the favicon.";
        type = types.str;
      };
      theme = mkOption {
        description = "Hardset the theme. 'light' or 'dark'";
        type = types.enum ["light" "dark"];
      };
      color = mkOption {
        description = "Hardset the color palette. options include slate, gray, zinc, neutral, stone, amber, yellow, lime, green, emerald, teal, cyan, sky, blue, indigo, violet, purple, fuchsia, pink, rose, red, white";
        type = types.enum ["slate" "gray" "zinc" "neutral" "stone" "amber" "yellow" "lime" "green" "emerald" "teal" "cyan" "sky" "blue" "indigo" "violet" "purple" "fuchsia" "pink" "rose" "red" "white"];
      };
      layout = mkOption {
        description = "Setup the service and bookmarks layouts.";
        type = types.attrsOf (types.submodule {
          options = {
            style = mkOption {
              description = "Whether the section is a row or column.";
              type = types.enum ["row" "column"];
            };
            columns = mkOption {
              description = "How many columns a row takes up. from 1 to 5.";
              type = types.ints.between 1 5;
            };
          };
        });
      };
    };
  };
  config = lib.mkIf cfg.enable {
    containers.homepage = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "brCont";
      localAddress = "${cfg.local}/16";
      bindMounts = {
        "/var/lib/private/homepage-dashboard" = {
          hostPath = "${config.custom.paths.vols}/homepage";
          isReadOnly = false;
        };
      };
      config = { config, pkgs, ... }: {
        services.homepage-dashboard = {
          enable = true;
          openFirewall = true;
        };
        networking = {
          useHostResolvConf = pkgs.lib.mkForce false;
          defaultGateway = "10.200.1.1";
          firewall = {
            enable = true;
          };
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
    };
  };
}

