{
  network.ports.http = {
    port = 8096;
    type = "tcp";
  };
  bindMounts = {
    "/var/lib/paperless" = {
      hostPath = "/Storage/volumes/paperless";
      isReadOnly = false;
    };
    "/var/lib/paperless/media" = {
      hostPath = "/Storage/media/paperless";
      isReadOnly = false;
    };
    /*
    Disable till I know how to create tmpdir in nixos from config
    "/var/lib/paperless/consume" = {
      hostPath = "/tmp/paperless_consume";
      isReadOnly = false;
    };
    */
  };
  secrets = [
    "paperless_superuser"
  ];
  config = {containerConfig,...}: {
    services = {
      paperless = {
        enable = true;
        port = containerConfig.network.ports.http.port;
        address = containerConfig.ip;
        user = "paperless";
        passwordFile = "/run/secrets/paperless_superuser";
        extraConfig = {
          PAPERLESS_URL="https://docs.faeranne.com";
          PAPERLESS_TRUSTED_PROXIES="10.200.0.1";
          PAPERLESS_USE_X_FORWARD_HOST=true;
          PAPERLESS_TASK_WORKERS=2;
          PAPERLESS_THREADS_PER_WORKER=1;
          PAPERLESS_CONSUMER_ENABLE_BARCODES=true;
          PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE=true;
          PAPERLESS_CONSUMER_ENABLE_TAG_BARCODE=true;
        };
      };
      redis.servers.paperless = {
        enable = true;
        port = 6379;
      };
    };
  };
}
