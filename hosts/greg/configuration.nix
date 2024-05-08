{config, ...}: {
  containers = {
    jellyfin = {
      privateNetwork = true;
      restartIfChanged = true;
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
      config = {config, lib, pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          jellyfin
          jellyfin-web
          jellyfin-ffmpeg
        ];
        services.jellyfin = {
          enable = true;
        };
        networking = {
          useHostResolvConf = lib.mkForce false;
          defaultGateway = "10.150.0.1";
          firewall.allowedTCPPorts = [ 8096 ];
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
    };
    rss = {
      privateNetwork = true;
      restartIfChanged = true;
      localAddress = "10.150.0.3/16";
      hostBridge = "brCont";
      bindMounts = {
        "/var/lib/freshrss" = {
          hostPath = "/Storage/volumes/freshrss";
          isReadOnly = false;
        };
        "/run/secrets/freshrss" = {
          hostPath = "${config.age.secrets."freshrss".path}";
          isReadOnly = true;
        };
      };
      config = {config, lib, pkgs, ...}: {
        services.freshrss = {
          enable = true;
          baseUrl = "https://rss.faeranne.com";
          defaultUser = "faeranne";
          passwordFile = "/run/secrets/freshrss";
        };
        networking = {
          useHostResolvConf = lib.mkForce false;
          defaultGateway = "10.150.0.1";
          firewall.allowedTCPPorts = [ 80 ];
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
    };
  };
  age.secrets.freshrss.rekeyFile = ./freshrss.age;
  services.traefik.dynamicConfigOptions.http = {
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
    };
    services = {
      jellyfin.loadBalancer.servers = [ {url = "http://10.150.0.2:8096"; } ];
      freshrss.loadBalancer.servers = [ {url = "http://10.150.0.3:80"; } ];
    };
  };
}
