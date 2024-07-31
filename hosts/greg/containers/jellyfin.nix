{
  network = {
    links = [
      "greg-traefik"
      "greg-servarr"
    ];
    ports.http = {
      port = 8096;
      type = "tcp";
    };
    isolate = false;
  };
  bindMounts = {
    "/media" = {
      hostPath = "/Storage/media";
    };
    "/var/lib/jellyfin" = {
      hostPath = "/Storage/volumes/jellyfin";
      isReadOnly = false;
    };
    "/config" = {
      hostPath = "/Storage/volumes/jellyfin";
      isReadOnly = false;
    };
  };
  gpu = true;
  tmpfs = [
    "/cache:rw"
  ];
  config = {config, pkgs, containerConfig, ...}: {
    nixpkgs.config.allowUnfree = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
        intel-media-driver
        intel-vaapi-driver # previously vaapiIntel
        vaapiVdpau
        intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      ];
    };
    environment.systemPackages = with pkgs; [
      cudatoolkit
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
      id3v2
      yt-dlp
    ];
    services.jellyfin = {
      enable = true;
    };
    system.stateVersion = "23.11";
  };
}
