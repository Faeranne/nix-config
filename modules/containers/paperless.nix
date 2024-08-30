{config, ...}:let
  containerName = "paperless";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.4/32"];
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/paperless" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/paperless/media" = {
        isReadOnly = false;
        create = true;
      };
      "/run/secrets/paperless_superuser" = {
        isReadOnly = false;
        hostPath = "${config.age.secrets.paperless_superuser.path}";
      };
    };

    specialArgs = {
      port = 8096;
    };

    config = {config, hostName, port, trustedProxy, ...}: {
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
          inherit port;
          enable = true;
          user = "paperless";
          passwordFile = "/run/secrets/paperless_superuser";
          settings = {
            PAPERLESS_URL="https://${hostName}";
            # Takes the list of addresses from the host network brCont (which is hardcoded for containers in `template.nix`
            # and fetches the address of the first entry.  This allows the container bridge address scope to be adjusted
            # without rewriting all containers.
            PAPERLESS_TRUSTED_PROXIES=toString trustedProxy;
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
