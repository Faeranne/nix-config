{self, config, myLib, pkgs, ...}:let
  containerName = "rss";
  inherit (myLib) getWireguardHost;
  myHost = self.topology.${pkgs.system}.config.nodes.${containerName}.parent;
  mkPeer = myLib.mkPeer myHost;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.7/32"]; #Prefer 10.100.1.x ips for containers
      listenPort = 51825; #listenPort must be globally unique.
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/freshrss" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
      };
      "/run/secrets/freshrss" = {
        hostPath = "${config.age.secrets.freshrss.path}";
        isReadOnly = false;
      };
    };

    specialArgs = {
      port = 80;
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
      services.freshrss = {
        enable = true;
        baseUrl = "https://${hostName}";
        defaultUser = "faeranne";
        passwordFile = "/run/secrets/freshrss";
      };
    };
  };
}
