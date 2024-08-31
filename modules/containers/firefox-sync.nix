{self, myLib, config, pkgs, ...}:let
  containerName = "firefoxsync";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.9/32"]; #Prefer 10.100.1.x ips for containers
      peers = [
      ];
    };
  };

  age.secrets.foxsync = {
    rekeyFile = self + "/secrets/containers/foxsync/secrets.age";
    mode = "770";
    generator.script = {pkgs, ...}: ''
      echo SYNC_MASTER_SECRET=`${pkgs.openssl}/bin/openssl rand -base64 32`
      echo SYNC_TOKEN_SERVER_FXA_METRICS_HASH_SECRET=`${pkgs.openssl}/bin/openssl rand -base64 32`
    '';
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/mysql" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
        create = true;
      };
      "/run/secrets/foxsync" = {
        isReadOnly = true;
        hostPath = config.age.secrets.foxsync.path;
      };
    };

    specialArgs = {
      port = 8096;
    };

    config = {config, port, ...}: {
      imports = [
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ port ];
        };
      };
      services.firefox-syncserver = {
        settings.port = port;
        singleNode = {
          enable = true;
          capacity = 4;
          hostname = "foxsync.faeranne.com";
          url = "https://foxsync.faeranne.com";
        };
        secrets = "/run/secrets/foxsync";
      };
    };
  };
}
