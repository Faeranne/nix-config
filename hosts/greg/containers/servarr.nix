{
  network.ports = {
    prowlarr = {
      port = 9696;
      type = "tcp";
    };
    sonarr = {
      port = 8989;
      type = "tcp";
    };
    radarr = {
      port = 7878;
      type = "tcp";
    };
    lidarr = {
      port = 8686;
      type = "tcp";
    };
    ombi = {
      port = 5000;
      type = "tcp";
    };
  };
  bindMounts = {
    "/var/lib/sonarr" = {
      hostPath = "/Storage/volumes/sonarr";
      isReadOnly = false;
    };
    "/var/lib/radarr" = {
      hostPath = "/Storage/volumes/radarr";
      isReadOnly = false;
    };
    "/var/lib/lidarr" = {
      hostPath = "/Storage/volumes/lidarr";
      isReadOnly = false;
    };
    "/var/lib/private/prowlarr" = {
      hostPath = "/Storage/volumes/prowlarr";
      isReadOnly = false;
    };
    "/var/lib/ombi" = {
      hostPath = "/Storage/volumes/ombi";
      isReadOnly = false;
    };
    "/transmission" = {
      hostPath = "/Storage/volumes/transmission";
      isReadOnly = false;
    };
    "/tv" = {
      hostPath = "/Storage/media/tv";
      isReadOnly = false;
    };
    "/movies" = {
      hostPath = "/Storage/media/movies";
      isReadOnly = false;
    };
    "/music" = {
      hostPath = "/Storage/media/music";
      isReadOnly = false;
    };
  };
  config = {...}: {
    services = {
      prowlarr.enable = true; 
      sonarr = {
        enable = true;
        dataDir = "/var/lib/sonarr";
        group = "users";
      };
      radarr = {
        enable = true;
        dataDir = "/var/lib/radarr";
        group = "users";
      };
      lidarr = {
        enable = true;
        dataDir = "/var/lib/lidarr";
        group = "users";
      };
      ombi.enable = true;
    };
  };
}
