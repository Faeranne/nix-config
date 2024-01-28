{ config, lib, pkgs, ... }:

{
  environment.persistence."/persist" = {
    directories = [
      "/etc/traefik"
    ];
  };

  services.traefik = {
    enable = true;
    dynamicConfigOptions = {
      http = {
        middlewares = {
          dash-auth.basicAuth.users = [
            "faeranne:$2y$05$E5K0KoncD2AmqaeKpWjMw.7M6jnvOG53SgJxIk2OzPqV8aSwXXW8u"
          ];
        };
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
}

