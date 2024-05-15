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
  };
  networking = {
    firewall = {
      allowedTCPPorts = [ 25565 9091 ];
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
    freshrss.rekeyFile = ./freshrss.age;
    openvpn_user.rekeyFile = ./openvpn_user.age;
    openvpn_pass.rekeyFile = ./openvpn_pass.age;
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
    };
    services = {
      jellyfin.loadBalancer.servers = [ {url = "http://10.200.0.2:8096"; } ];
      freshrss.loadBalancer.servers = [ {url = "http://10.200.0.3:80"; } ];
      grocy.loadBalancer.servers = [ {url = "http://10.200.0.4:80"; } ];
    };
  };
}
