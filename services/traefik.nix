{ config, lib, pkgs, ... }:
let
  baseURL = config.custom.baseURL;
  routes = config.custom.traefik.routes;
  enable = config.custom.traefik.enable;
in
{
  options.custom = {
    baseURL = lib.mkOption {
      description = "The Base url for Traefik and other services.";
      type = lib.types.str;
    };
    traefik.enable = lib.mkEnableOption {
      description = "Whether to use Traefik";
    };
    traefik.routes = lib.mkOption {
      default = [];
      description = "What traefik forwards to include";
      type = lib.types.attrsOf (with lib; types.submodule {
        options = {
          target = mkOption {
            type = types.str;
          };
          rule = mkOption {
            type = types.str;
          };
          middlewares = mkOption {
            default = [];
            type = types.listOf types.str;
          };
        };
      });
    };
  };
  config = lib.mkIf enable {
    environment.persistence."/persist" = {
      directories = [
        "/etc/traefik"
      ];
    };

    services.traefik = {
      enable = true;
      dynamicConfigOptions.http = {
        routers = (lib.mapAttrs (name: attrs: {
          rule = attrs.rule;
          service = name;
          entryPoints = [ "websecure" ];
          middlewares = attrs.middlewares;
        }) routes) // {
          dashboard = {
            rule = "Host(`traefik.${baseURL}`)";
            service = "api@internal";
            entryPoints = [ "websecure" ];
            middlewares = [ "dash-auth" ];
          };
        };
        services = lib.mapAttrs (name: attrs: {
          loadBalancer.servers = [ {url = attrs.target;} ];
        }) routes;
        middlewares = {
          dash-auth.basicAuth.users = [
            #Should this be behind a secrets.yaml file? probably. Does it matter? nope.
            #it's protecting the traefik dashboard.  That's mostly read-only, so worst
            #case I just disable the dashboard.
            "faeranne:$2y$05$E5K0KoncD2AmqaeKpWjMw.7M6jnvOG53SgJxIk2OzPqV8aSwXXW8u"
          ];
        };
      };
      staticConfigOptions = {
        entryPoints = { 
          internal = {
            address = ":81";
          };
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure = {
            address = ":443";
            http.tls.certResolver = "leresolver";
          };
        };
        certificatesresolvers.leresolver.acme = {
          #Yeah, my email is visible here. it's also visible in the git log, so I don't care.
          email = "nina@projectmakeit.com";
          storage = "/etc/traefik/acme.json";
          httpchallenge.entrypoint = "web";
        };
        api.dashboard = true;
        ping.entrypoint = "internal";
      };

      dataDir = "/etc/traefik/";
    };
    networking = {
      firewall = {
        allowedTCPPorts = [ 80 443 ];
      };
    };
  };
}
