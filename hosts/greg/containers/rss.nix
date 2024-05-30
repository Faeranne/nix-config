{
  network = {
    links = [
      "greg-traefik"
    ];
    ports.http = {
      port = 80;
      type = "tcp";
    };
    isolate = false;
  };
  bindMounts = {
    "/var/lib/freshrss" = {
      hostPath = "/Storage/volumes/freshrss";
      isReadOnly = false;
    };
  };
  secrets = [
    "freshrss"
  ];
  config = {config, lib, pkgs, ...}: {
    services.freshrss = {
      enable = true;
      baseUrl = "https://rss.faeranne.com";
      defaultUser = "faeranne";
      passwordFile = "/run/secrets/freshrss";
    };
    system.stateVersion = "23.11";
  };
}
