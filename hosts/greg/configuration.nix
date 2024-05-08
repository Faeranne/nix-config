{...}: {
  containers = {
    jellyfin = {
      privateNetwork = true;
      localAddress = "10.150.0.2/16";
      hostBridge = "brCont";
      tmpfs = [ "/cache" ];
      bindMounts = {
        "/media" = {
          hostPath = "/Storage/media";
        };
        "/var/lib/jellyfin" = {
          hostPath = "/Storage/volumes/jellyfin";
          isReadOnly = false;
        };
      };
      config = {config, pkgs, ...}: {
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
    };
  };
}
