{config, ...}: {
  virtualisation.oci-containers.containers = {
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
      allowedTCPPorts = [ 25565 ];
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
