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
    "github_runner1"
  ];
  config = {config, lib, pkgs, ...}: {
    services = {
      github-runners = {
        runner1 = {
          enable = true;
          name = "runner1";
          tokenFile = "/run/secrets/github_runner1";
          url = "https://github.com/faeranne/Trade-Station";
          nodeRuntimes = [
            "node20"
          ];
          extraLabels = [
            "nixos"
            "home"
          ];
        };
      };
    };
    system.stateVersion = "23.11";
  };
}
