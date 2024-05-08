{systemConfig, lib, ...}: let
  isImpermanent = (builtins.elem "impermanence" systemConfig.elements);
  isTraefik = (builtins.elem "traefik" systemConfig.elements);
in {
  services.traefik = lib.mkIf isTraefik {
    enable = isTraefik;
    environment.persistence = lib.mkIf isImpermanent = {
      "/persist" = {
        directories = [
          "/etc/traefik"
        ];
      };
    };
    dataDir = "/etc/traefik";
    staticConfigOptions = {
      entryPoints = {
        internal.address = "127.0.0.1:81";
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
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
