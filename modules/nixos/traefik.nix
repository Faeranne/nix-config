#Hey, so no real notes here because this eventually needs to become a
#container.  Rely on it at your own disgression
{systemConfig, lib, ...}: let
  isImpermanent = (builtins.elem "impermanence" systemConfig.elements);
  isTraefik = (builtins.elem "traefik" systemConfig.elements);
in {
  environment.persistence = lib.mkIf (isTraefik && isImpermanent) {
    "/persist" = {
      directories = [
        "/etc/traefik"
      ];
    };
  };
  services.traefik = lib.mkIf isTraefik {
    enable = true;
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
      api.dashboard = true;
      ping.entrypoint = "internal";
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
