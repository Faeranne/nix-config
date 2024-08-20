{self, myLib, config, pkgs, ...}:let
  containerName = "firefox-sync";
  inherit (myLib) getWireguardHost;
  myHost = self.topology.${pkgs.system}.config.nodes.${containerName}.parent;
  mkPeer = myLib.mkPeer myHost;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.9/32"]; #Prefer 10.100.1.x ips for containers
      listenPort = 51827; #listenPort must be globally unique.
      peers = [
        #See mkPeer below for more info
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
      };
      "/run/secrets/foxsync" = {
        isReadOnly = true;
        hostPath = config.age.secrets.foxsync.path;
      };
    };

    config = {config, pkgs, ...}: {
      imports = [
        # Covers some basic values, as well as fixing some potentially buggy networking issues
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ config.services.firefox-syncserver.settings.port ];
        };
      };
      services.firefox-syncserver = {
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
