{config, ...}:{
  imports = [
    (import ./template.nix "paperless")
  ];
  containers.paperless = {
    bindMounts = {
      "/var/lib/paperless" = {
        isReadOnly = false;
      };
      "/var/lib/paperless/media" = {
        isReadOnly = false;
      };
    };
    config = let 
      hostConfig = config;
    in {config, hostName, ...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ config.services.paperless.port ];
        };
      };
      services = {
        paperless = {
          enable = true;
          port = 8096;
          user = "paperless";
          passwordFile = "/run/secrets/paperless_superuser";
          settings = {
            PAPERLESS_URL="https://${hostName}";
            # Takes the list of addresses from the host network brCont (which is hardcoded for containers in `template.nix`
            # and fetches the address of the first entry.  This allows the container bridge address scope to be adjusted
            # without rewriting all containers.
            PAPERLESS_TRUSTED_PROXIES=(builtins.elemAt hostConfig.networking.interfaces.brCont.addresses 0).address;
            PAPERLESS_USE_X_FORWARD_HOST=true;
            PAPERLESS_TASK_WORKERS=2;
            PAPERLESS_THREADS_PER_WORKER=1;
            PAPERLESS_CONSUMER_ENABLE_BARCODES=true;
            PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE=true;
            PAPERLESS_CONSUMER_ENABLE_TAG_BARCODE=true;
          };
        };
      };
    };
  };
}
