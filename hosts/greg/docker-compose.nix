# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, config, ... }:

{

  # Containers
  virtualisation.oci-containers.containers."obico-ml_api" = {
    image = "localhost/compose2nix/obico-ml_api";
    environment = {
      "DEBUG" = "True";
      "FLASK_APP" = "server.py";
    };
    cmd = [ "bash" "-c" "gunicorn --bind 0.0.0.0:3333 --workers 1 wsgi" ];
    log-driver = "journald";
    extraOptions = [
      "--device=nvidia.com/gpu=all"
      "--health-cmd=wget --no-verbose --tries=1 --spider --no-check-certificate http://ml_api:3333/hc/"
      "--health-interval=30s"
      "--health-retries=3"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--hostname=ml_api"
      "--network-alias=ml_api"
      "--network=obico_default"
      "--security-opt=label=disable"
    ];
  };
  systemd.services."podman-obico-ml_api" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-obico_default.service"
    ];
    requires = [
      "podman-network-obico_default.service"
    ];
    partOf = [
      "podman-compose-obico-root.target"
    ];
    wantedBy = [
      "podman-compose-obico-root.target"
    ];
  };
  virtualisation.oci-containers.containers."obico-redis" = {
    image = "redis:7.2-alpine";
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"redis-cli\", \"--raw\", \"incr\", \"ping\"]"
      "--health-interval=15s"
      "--health-retries=20"
      "--health-start-period=15s"
      "--health-timeout=10s"
      "--network-alias=redis"
      "--network=obico_default"
    ];
  };
  systemd.services."podman-obico-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-obico_default.service"
    ];
    requires = [
      "podman-network-obico_default.service"
    ];
    partOf = [
      "podman-compose-obico-root.target"
    ];
    wantedBy = [
      "podman-compose-obico-root.target"
    ];
  };
  virtualisation.oci-containers.containers."obico-tasks" = {
    image = "localhost/compose2nix/obico-tasks";
    environment = {
      "ACCOUNT_ALLOW_SIGN_UP" = "False";
      "CSRF_TRUSTED_ORIGINS" = "[\"https://obico.faeranne.com\"]";
      "DATABASE_URL" = "sqlite:////app/db.sqlite3";
      "DEBUG" = "False";
      "DEFAULT_FROM_EMAIL" = "changeme@example.com";
      "INTERNAL_MEDIA_HOST" = "http://web:3334";
      "ML_API_HOST" = "http://ml_api:3333";
      "OCTOPRINT_TUNNEL_PORT_RANGE" = "0-0";
      "REDIS_URL" = "redis://redis:6379";
      "SITE_IS_PUBLIC" = "True";
      "SITE_USES_HTTPS" = "True";
      "WEBPACK_LOADER_ENABLED" = "False";
    };
    environmentFiles = [
      "${config.age.secrets.obico.path}"
    ];
    volumes = [
      "/Storage/volumes/obico-server/app:/app:rw"
      "/Storage/volumes/obico-server/frontend:/frontend:rw"
    ];
    cmd = [ "sh" "-c" "celery -A config worker --beat -l info -c 2 -Q realtime,celery" ];
    dependsOn = [
      "obico-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=celery -A config inspect ping"
      "--health-interval=30s"
      "--health-retries=3"
      "--health-start-period=15s"
      "--health-timeout=10s"
      "--hostname=tasks"
      "--network-alias=tasks"
      "--network=obico_default"
    ];
  };
  systemd.services."podman-obico-tasks" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-obico_default.service"
    ];
    requires = [
      "podman-network-obico_default.service"
    ];
    partOf = [
      "podman-compose-obico-root.target"
    ];
    wantedBy = [
      "podman-compose-obico-root.target"
    ];
  };
  virtualisation.oci-containers.containers."obico-web" = {
    image = "localhost/compose2nix/obico-web";
    environment = {
      "ACCOUNT_ALLOW_SIGN_UP" = "False";
      "CSRF_TRUSTED_ORIGINS" = "[\"https://obico.faeranne.com\"]";
      "DATABASE_URL" = "sqlite:////app/db.sqlite3";
      "DEBUG" = "False";
      "DEFAULT_FROM_EMAIL" = "changeme@example.com";
      "INTERNAL_MEDIA_HOST" = "http://web:3334";
      "ML_API_HOST" = "http://ml_api:3333";
      "OCTOPRINT_TUNNEL_PORT_RANGE" = "0-0";
      "REDIS_URL" = "redis://redis:6379";
      "SITE_IS_PUBLIC" = "True";
      "SITE_USES_HTTPS" = "True";
      "WEBPACK_LOADER_ENABLED" = "False";
    };
    environmentFiles = [
      "${config.age.secrets.obico.path}"
    ];
    volumes = [
      "/Storage/volumes/obico-server/app:/app:rw"
      "/Storage/volumes/obico-server/frontend:/frontend:rw"
    ];
    ports = [
      "3334:3334/tcp"
    ];
    cmd = [ "sh" "-c" "python manage.py migrate && python manage.py collectstatic -v 2 --noinput && daphne -b 0.0.0.0 -p 3334 config.routing:application" ];
    dependsOn = [
      "obico-ml_api"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=wget --no-verbose --tries=1 --spider --no-check-certificate http://web:3334/hc/"
      "--health-interval=1m30s"
      "--health-retries=3"
      "--health-start-period=30s"
      "--health-timeout=20s"
      "--hostname=web"
      "--network-alias=web"
      "--network=obico_default"
    ];
  };
  systemd.services."podman-obico-web" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-obico_default.service"
    ];
    requires = [
      "podman-network-obico_default.service"
    ];
    partOf = [
      "podman-compose-obico-root.target"
    ];
    wantedBy = [
      "podman-compose-obico-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-obico_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f obico_default";
    };
    script = ''
      podman network inspect obico_default || podman network create obico_default
    '';
    partOf = [ "podman-compose-obico-root.target" ];
    wantedBy = [ "podman-compose-obico-root.target" ];
  };

  # Builds
  systemd.services."podman-build-obico-ml_api" = {
    path = [ pkgs.podman pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      podman build -t compose2nix/obico-ml_api https://github.com/TheSpaghettiDetective/obico-server.git#release:ml_api
    '';
  };
  systemd.services."podman-build-obico-tasks" = {
    path = [ pkgs.podman pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      podman build -t compose2nix/obico-tasks https://github.com/TheSpaghettiDetective/obico-server.git#release:backend
    '';
  };
  systemd.services."podman-build-obico-web" = {
    path = [ pkgs.podman pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      podman build -t compose2nix/obico-web https://github.com/TheSpaghettiDetective/obico-server.git#release:backend
    '';
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-obico-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
