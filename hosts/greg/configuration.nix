{config, ...}: {
  virtualisation.oci-containers.containers = {
    "gluetun" = {
      autoStart = true;
      image = "qmcgaw/gluetun";
      hostname = "gluetun";
      ports = [
        "9091:9091"
      ];
      environment = {
        PUID="999";
        GUID="100";
        VPN_SERVICE_PROVIDER="private internet access";
        SERVER_REGIONS="Switzerland";
        TZ="AmericaIndiana";
        VPN_PORT_FORWARDING="on";
        VPN_PORT_FORWARDING_STATUS_FILE="/mnt/gluetun_port/forwarded_port";
      };
      volumes = [
        "/Storage/volumes/gluetun:/gluetun"
        "${config.age.secrets."openvpn_user".path}:/run/secrets/openvpn_user"
        "${config.age.secrets."openvpn_pass".path}:/run/secrets/openvpn_password"
        "/Storage/volumes/gluetun_port:/mnt/gluetun_port"
      ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
        "--ip=10.88.1.2"
      ];
    };
    transmission = {
      autoStart = true;
      image = "lscr.io/linuxserver/transmission:latest";
      environment = {
        PUID="999";
        GUID="100";
        TZ="America/Indiana";
        TRANSMISSION_WEB_HOME="/transmission";
      };
      volumes = [
        "/Storage/volumes/transmission:/config"
        "/Storage/volumes/transmission:/downloads"
        "/Storage/volumes/gluetun_port:/mnt/gluetun_port"
      ];
      dependsOn = [ "gluetun" ];
      extraOptions = [
        "--network=container:gluetun"
      ];
    };
    "dominom-minecraft" = {
      autoStart = true;
      image = "itzg/minecraft-server";
      volumes = [
        "/Storage/volumes/minecraft/dominom:/data"
      ];
      ports = [
        "25565:25565"
      ];
      environment = {
        UID="1000";
        EULA="true";
        MEMORY="4G";
        ENABLE_ROLLING_LOGS="true";
        USE_AIKAR_FLAGS="true";
        TYPE="FORGE";
        VERSION="1.18.2";
        FORGE_VERSION="40.2.21";
        MAX_PLAYERS="2";
        SNOOPER_ENABLE = "false";
        ALLOW_FLIGHT="true";
        GUI="false";
        MOTD="Create: Computers";
        ENABLE_WHITELIST="true";
        ENFORCE_WHITELIST="true";
        OPS="faeranne";
        SPAWN_PROTECTION="0";
      };
    };
    "wizarr" = {
      autoStart = true;
      image = "ghcr.io/wizarrrr/wizarr:4.1.0";
      volumes = [
        "/Storage/volumes/wizarr:/data/database"
      ];
      ports = [
        "5690:5690"
      ];
      environment = {
      };
      extraOptions = [
        "--ip=10.88.1.3"
      ];
    };
  };
  networking = {
    firewall = {
      allowedTCPPorts = [ 25565 9091 80 443 ];
    };
    nat.forwardPorts = [
      {
        destination = "10.88.1.2:9091";
        sourcePort = 9091;
        proto = "tcp";
      }
    ];
  };
  age.secrets = {
    freshrss.rekeyFile = ./secrets/freshrss.age;
    openvpn_user.rekeyFile = ./secrets/openvpn_user.age;
    openvpn_pass.rekeyFile = ./secrets/openvpn_pass.age;
    paperless_superuser = {
      rekeyFile = ./secrets/paperless_superuser.age;
      generator = {
        script = "passphrase";
        tags = [ "pregen" ];
      };
    };
  };
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
    };
    services = {
      jellyfin.loadBalancer.servers = [ {url = "http://10.200.0.2:8096"; } ];
      freshrss.loadBalancer.servers = [ {url = "http://10.200.0.3:80"; } ];
      grocy.loadBalancer.servers = [ {url = "http://10.200.0.4:80"; } ];
      prowlarr.loadBalancer.servers = [ {url = "http://10.200.0.5:9696"; } ];
      sonarr.loadBalancer.servers = [ {url = "http://10.200.0.5:8989"; } ];
      radarr.loadBalancer.servers = [ {url = "http://10.200.0.5:7878"; } ];
      lidarr.loadBalancer.servers = [ {url = "http://10.200.0.5:8686"; } ];
      bazarr.loadBalancer.servers = [ {url = "http://10.200.0.5:6767"; } ];
      ombi.loadBalancer.servers = [ {url = "http://10.200.0.5:5000"; } ];
      wizarr.loadBalancer.servers = [ {url = "http://10.88.1.3:5690"; } ];
      paperless.loadBalancer.servers = [ {url = "http://10.200.0.6:8096"; } ];
    };
  };
  services.zfs.autoScrub.pools = [ "Storage" ];
}
