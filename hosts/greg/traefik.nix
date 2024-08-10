{config, ...}: {
  services = {
    traefik.dynamicConfigOptions.http = {
      routers = {
        dashboard = {
          rule = "Host(`traefik.home.faeranne.com`)";
          service = "api@internal";
          entryPoints = [ "websecure" ];
          #middlewares = [ "dash-auth" ];
        };
        jellyfin = {
          rule = "Host(`tv.faeranne.com`)";
          service = "jellyfin";
          entryPoints = [ "websecure" ];
        };
        freshrss = {
          rule = "Host(`rss.faeranne.com`)";
          service = "freshrss";
          entryPoints = [ "websecure" ];
        };
        grocy = {
          rule = "Host(`grocy.faeranne.com`)";
          service = "grocy";
          entryPoints = [ "websecure" ];
        };
        prowlarr = {
          rule = "Host(`prowlarr.faeranne.com`)";
          service = "prowlarr";
          entryPoints = [ "websecure" ];
        };
        sonarr = {
          rule = "Host(`sonarr.faeranne.com`)";
          service = "sonarr";
          entryPoints = [ "websecure" ];
        };
        radarr = {
          rule = "Host(`radarr.faeranne.com`)";
          service = "radarr";
          entryPoints = [ "websecure" ];
        };
        lidarr = {
          rule = "Host(`lidarr.faeranne.com`)";
          service = "lidarr";
          entryPoints = [ "websecure" ];
        };
        bazarr = {
          rule = "Host(`bazarr.faeranne.com`)";
          service = "bazarr";
          entryPoints = [ "websecure" ];
        };
        ombi = {
          rule = "Host(`request.faeranne.com`)";
          service = "ombi";
          entryPoints = [ "websecure" ];
        };
        wizarr = {
          rule = "Host(`wizarr.faeranne.com`)";
          service = "wizarr";
          entryPoints = [ "websecure" ];
        };
        paperless = {
          rule = "Host(`paperless.faeranne.com`)";
          service = "paperless";
          entryPoints = [ "websecure" ];
        };
        actual = {
          rule = "Host(`actual.faeranne.com`)";
          service = "actual";
          entryPoints = [ "websecure" ];
        };
      };
      services = {
        jellyfin.loadBalancer.servers = [ {url = "http://${config.containers.jellyfin.localAddress}:8096"; } ];
        freshrss.loadBalancer.servers = [ {url = "http://10.200.0.3:80"; } ];
        grocy.loadBalancer.servers = [ {url = "http://${config.containers.jellyfin.localAddress}:80"; } ];
        prowlarr.loadBalancer.servers = [ {url = "http://10.200.0.5:9696"; } ];
        sonarr.loadBalancer.servers = [ {url = "http://10.200.0.5:8989"; } ];
        radarr.loadBalancer.servers = [ {url = "http://10.200.0.5:7878"; } ];
        lidarr.loadBalancer.servers = [ {url = "http://10.200.0.5:8686"; } ];
        bazarr.loadBalancer.servers = [ {url = "http://10.200.0.5:6767"; } ];
        ombi.loadBalancer.servers = [ {url = "http://10.200.0.5:5000"; } ];
        wizarr.loadBalancer.servers = [ {url = "http://10.88.1.3:5690"; } ];
        paperless.loadBalancer.servers = [ {url = "http://10.200.0.6:8096"; } ];
        actual.loadBalancer.servers = [ {url = "http://10.88.1.4:5006"; } ];
      };
    };
  };
}
