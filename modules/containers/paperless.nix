{self, myLib, config, pkgs, ...}:let
  containerName = "paperless";
  inherit (myLib) getWireguardHost;
  myHost = self.topology.${pkgs.system}.config.nodes.${containerName}.parent;
  mkPeer = myLib.mkPeer myHost;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.4/32"];
      listenPort = 51822;
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/paperless" = {
        isReadOnly = false;
      };
      "/var/lib/paperless/media" = {
        isReadOnly = false;
      };
      "/run/secrets/paperless_superuser" = {
        isReadOnly = false;
        hostPath = "${config.age.secrets.paperless_superuser.path}";
      };
    };

    config = let 
      hostConfig = config;
    in {config, hostName, trustedProxy, ...}: {
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
