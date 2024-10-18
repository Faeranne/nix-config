{config, ...}:let
  containerName = "nixcache";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.14/32"]; #Prefer 10.100.1.x ips for containers
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/nixcache" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
        create = true;
      };
      "/run/secrets/nixcache" = {
        hostPath = "/persist/cache-priv-key.pem";
        isReadOnly = true;
      };
    };

    specialArgs = {
      port = 5000;
    };

    config = {hostName, port, ...}: {
      imports = [
        # Covers some basic values, as well as fixing some potentially buggy networking issues
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ port ];
        };
      };
      services.nix-serve = {
        enable = true;
        secretKeyFile = "/run/secrets/nixcache";
      };
    };
  };
}
