{
  network = {
    links = [
      "greg-traefik"
    ];
    ports.http = {
      port = 80;
      type = "tcp";
    };
  };
  bindMounts = {
    "/var/lib/grocy" = {
      hostPath = "/Storage/volumes/grocy";
      isReadOnly = false;
    };
  };
  config = {...}: {
    services.grocy = {
      enable = true;
      hostName = "grocy.faeranne.com";
      nginx.enableSSL = false;
      settings = {
        currency = "USD";
        culture = "en";
        calendar = {
          showWeekNumber = true;
          firstDayOfWeek = 0;
        };
      };
    };
    system.stateVersion = "23.11";
  };
}
