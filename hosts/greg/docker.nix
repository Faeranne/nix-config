{
  self, 
  config,
  ...
}: {
  age.secrets = {
    sharkeyenv = {
      rekeyFile = self + "/secrets/containers/sharkey/env.age";
    };
    ehterpadenv = {
      rekeyFile = self + "/secrets/containers/etherpad/env.age";
    };
  };
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
    "etherpad" = {
      autoStart = true;
      image = "etherpad/etherpad:2.2.7";
      ports = [
      ];
      environment = {
        NODE_ENV = "production";
        DB_CHARSET = "utf8mb4";
        DB_HOST = "10.88.1.10";
        DB_PORT = "5432";
        DB_TYPE = "postgres";
        DB_USER = "etherpad";
        TRUST_PROXY = "true";
        DEFAULT_PAD_TEXT = " ";
        DISABLE_IP_LOGGING="false";
        SOFFICE = "null";
      };
      environmentFiles = [
        config.age.secrets.etherpadenv.path
      ];
      volumes = [
        "/Storage/volumes/etherpad/data:/opt/etherpad-lite/var"
        "/Storage/volumes/etherpad/plugins:/opt/etherpad-lite/src/plugin_packages"
      ];
      dependsOn = [
        "etherpad-db"
      ];
      extraOptions = [
        "--ip=10.88.1.10"
      ];
    };
    "etherpad-db" = {
      autoStart = true;
      image = "postgres:15-alpine";
      ports = [
      ];
      environment = {
      };
      environmentFiles = [
        config.age.secrets.etherpadenv.path
      ];
      volumes = [
        "/Storage/volumes/etherpad/db:/var/lib/postgresql/data"
      ];
      extraOptions = [
        "--ip=10.88.1.9"
      ];
    };
    "sharkey-db" = {
      autoStart = true;
      image = "postgres:15-alpine";
      ports = [
      ];
      environment = {

      };
      environmentFiles = [
        config.age.secrets.sharkeyenv.path
      ];
      volumes = [
        "/Storage/volumes/sharkey/db:/var/lib/postgresql/data"
      ];
      extraOptions = [
        "--ip=10.88.1.8"
      ];
    };
    "sharkey-redis" = {
      autoStart = true;
      image = "redis:7-alpine";
      ports = [
      ];
      environment = {
      };
      volumes = [
        "/Storage/volumes/sharkey/redis:/data"
      ];
      extraOptions = [
        "--ip=10.88.1.7"
      ];
    };
    "sharkey-web" = {
      autoStart = true;
      image = "registry.activitypub.software/transfem-org/sharkey:2024.9.4";
      ports = [
      ];
      environment = {
      };
      environmentFiles = [
        config.age.secrets.sharkeyenv.path
      ];
      volumes = [
        "/Storage/volumes/sharkey/files:/sharkey/files"
        "${./sharkey.yaml}:/sharkey/.config/default.yml:ro"
      ];
      dependsOn = [
        "sharkey-db"
        "sharkey-redis"
      ];
      extraOptions = [
        "--ip=10.88.1.6"
      ];
    };
    "lubelogger" = {
      autoStart = true;
      image = "ghcr.io/hargata/lubelogger:v1.3.9";
      ports = [
        "8080:8080"
      ];
      environment = {
        LC_ALL = "en_US";
        LANG = "en_US";
        LUBELOGGER_LOGO_URL = "https://cloud.faeranne.com/s/qSnYxnzi7pbCWKT/download/logo64.png";
      };
      volumes = [
        "/Storage/volumes/lubelogger/config:/App/config"
        "/Storage/volumes/lubelogger/data:/App/data"
        "/Storage/volumes/lubelogger/translations:/App/translations"
        "/Storage/volumes/lubelogger/documents:/App/documents"
        "/Storage/volumes/lubelogger/images:/App/images"
        "/Storage/volumes/lubelogger/temp:/App/temp"
        "/Storage/volumes/lubelogger/log:/App/log"
        "/Storage/volumes/lubelogger/keys:/App/keys"
      ];
      extraOptions = [
        "--ip=10.88.1.5"
      ];
    };
    "actual" = {
      autoStart = true;
      image = "actualbudget/actual-server:24.11.0";
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
        PUID = "999";
        GUID = "100";
        VPN_SERVICE_PROVIDER = "mullvad";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Sweden";
        SERVER_CITIES = "Gothenburg";
        TZ = "America/Indiana/Indianapolis";
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
        PUID = "999";
        GUID = "100";
        TZ = "America/Indiana";
        TRANSMISSION_WEB_HOME = "/transmission";
      };
      volumes = [
        "/Storage/volumes/transmission:/config"
        "/Storage/volumes/transmission:/downloads"
        "/Storage/volumes/gluetun_port:/mnt/gluetun_port"
      ];
      dependsOn = ["gluetun"];
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
