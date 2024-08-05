{config, lib, ...}: {
  environment.persistence = lib.mkIf config.nexus.storage.impermanence {
    "/persist" = {
      directories = [
        "/etc/traefik"
      ];
    };
  };
  services.traefik = {
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
