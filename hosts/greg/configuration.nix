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
  services.traefik.dynamicConfigOptions.http = {
    routers = {
      #dashboard = {
      #  rule = "Host(`traefik.home.faeranne.com`)";
      #  service = "api@internal";
      #  entryPoints = [ "websecure" ];
      #  #middlewares = [ "dash-auth" ];
      #};
      jellyfin = {
        rule = "Host(`tv.faeranne.com`)";
        service = "jellyfin";
        entryPoints = [ "websecure" ];
      };
    };
    services = {
      jellyfin.loadBalancers.servers = [ {url = "http://10.150.0.2:8096"; } ];
    };
    middlewares = {
    };
  };
}
