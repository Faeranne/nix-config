{
  network.ports.http = {
    port = 8096;
    type = "tcp";
  };
  bindMounts = {
    "/media" = {
      hostPath = "/Storage/media";
    };
    "/var/lib/jellyfin" = {
      hostPath = "/Storage/volumes/jellyfin";
      isReadOnly = false;
    };
  };
  tmpfs = [
    "/cache"
  ];
  config = {config, pkgs, containerConfig, ...}: {
    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];
    services.jellyfin = {
      enable = true;
    };
    system.stateVersion = "23.11";
  };
}