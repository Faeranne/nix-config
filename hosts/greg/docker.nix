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
    "lubelogger" = {
      autoStart = true;
      image = "ghcr.io/hargata/lubelogger:v1.3.9";
      ports = [
        "8080:8080"
      ];
      environment = {
        LC_ALL="en_US";
        LANG="en_US";
        LUBELOGGER_LOGO_URL="https://cloud.faeranne.com/s/bTkqNMymYAdP5Ww/download/g1061.png";
      };
      volumes = [
        "config:/Storage/volumes/lubelogger/config"
        "data:/Storage/volumes/lubelogger/data"
        "translations:/Storage/volumes/lubelogger/translations"
        "documents:/Storage/volumes/lubelogger/documents"
        "images:/Storage/volumes/lubelogger/images"
        "temp:/Storage/volumes/lubelogger/temp"
        "log:/Storage/volumes/lubelogger/log"
        "keys:/Storage/volumes/lubelogger/keys"
      ];
      extraOptions = [
        "--ip=10.88.1.5"
      ];
    };
    "actual" = {
      autoStart = true;
      image = "actualbudget/actual-server:24.10.1";
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
        PUID="999"; GUID="100";
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
