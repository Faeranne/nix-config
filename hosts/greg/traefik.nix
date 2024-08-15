{config, ...}: {
  services = {
    traefik.dynamicConfigOptions.http = {
      routers = {
        # This host is internal, so we good with just this
        dashboard = {
          rule = "Host(`traefik.home.faeranne.com`)";
          service = "api@internal";
          entryPoints = [ "websecure" ];
          #middlewares = [ "dash-auth" ];
        };
        # The hostname for these containers is not declaritively set, so this is the best we get.
        jellyfin = {
          rule = "Host(`tv.faeranne.com`)";
          service = "jellyfin";
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
        actual = {
          rule = "Host(`actual.faeranne.com`)";
          service = "actual";
          entryPoints = [ "websecure" ];
        };
        # The rest of these are all completely declaritively set, so we can just use them dynamically
        freshrss = {
          rule = "Host(`${config.containers.jellyfin.specialArgs.hostName}`)";
          service = "freshrss";
          entryPoints = [ "websecure" ];
        };
        grocy = {
          rule = "Host(`${config.containers.grocy.specialArgs.hostName}`)";
          service = "grocy";
          entryPoints = [ "websecure" ];
        };
        paperless = {
          rule = "Host(`${config.containers.paperless.specialArgs.hostName}`)";
          service = "paperless";
          entryPoints = [ "websecure" ];
        };
      };
      services = {
        # these services don't use declaritive configs, so we have to manually set the ports using the defaults
        jellyfin.loadBalancer.servers = [ {url = "http://${config.containers.jellyfin.localAddress}:8096"; } ];
        prowlarr.loadBalancer.servers = [ {url = "http://10.200.0.5:9696"; } ];
        sonarr.loadBalancer.servers = [ {url = "http://10.200.0.5:8989"; } ];
        radarr.loadBalancer.servers = [ {url = "http://10.200.0.5:7878"; } ];
        lidarr.loadBalancer.servers = [ {url = "http://10.200.0.5:8686"; } ];
        bazarr.loadBalancer.servers = [ {url = "http://10.200.0.5:6767"; } ];
        ombi.loadBalancer.servers = [ {url = "http://10.200.0.5:5000"; } ];
        # these are docker containers, which again... we can't declaritively set the ports *and* there's no simple way to get
        # the ports *or* ips for them, so we just hardcode them, both ip and port
        wizarr.loadBalancer.servers = [ {url = "http://10.88.1.3:5690"; } ];
        actual.loadBalancer.servers = [ {url = "http://10.88.1.4:5006"; } ];
        # these all have dynamically set ports, so we can just fetch them from configs instead. :3
        freshrss.loadBalancer.servers = [ {url = "http://${config.containers.freshrss.localAddress}:${config.containers.freshrss.config.nginx.port}"; } ];
        grocy.loadBalancer.servers = [ {url = "http://${config.containers.grocy.localAddress}:${config.containers.grocy.config.nginx.port}"; } ];
        paperless.loadBalancer.servers = [ {url = "http://${config.containers.paperless.localAddress}:${config.containers.paperless.config.paperless.port}"; } ];
      };
    };
  };
}
