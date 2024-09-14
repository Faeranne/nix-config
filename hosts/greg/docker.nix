{config, ...}:{
  virtualisation.oci-containers.containers = {
    /*
    "fasten" = {
      autoStart = true;
      image = "ghcr.io/fastenhealth/fasten-onprem:sandbox";
      ports = [
      ];
      environment = {
      };
      volumes = [
      ];
      extraOptions = [
        "--ip=10.88.1.6"
      ];
    };
    */
    "actual" = {
      autoStart = true;
      image = "actualbudget/actual-server:24.9.0";
      ports = [
        "5006:5006"
      ];
      environment = {
      };
      volumes = [
        "/Storage/volumes/actual:/data"
      ];
      extraOptions = [
        "--ip=10.88.1.4"
      ];
    };
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
        VPN_SERVICE_PROVIDER="mullvad";
        VPN_TYPE="wireguard";
        SERVER_COUNTRIES="Sweden";
        SERVER_CITIES="Gothenburg";
        TZ="America/Indiana/Indianapolis";
      };
      volumes = [
        "/Storage/volumes/gluetun:/gluetun"
        "${config.age.secrets."mullvad".path}:/run/secrets/wireguard_private_key"
        "${config.age.secrets."mullvad_address".path}:/run/secrets/wireguard_addresses"
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
      extraOptions = [
        "--ip=10.88.1.5"
      ];
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
}
