{
  ports = {
    jellyfin-web = {
      tcp = 8096;
    };
  };
  paths = {
    host = {
      "media" = "/media";
      "config" = "/var/lib/jellyfin";
    };
    temp = [
      "/cache"
    ];
  };
  secrets = [
    
  ];
}
