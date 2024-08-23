{config, ...}:let
  containerName = "githubrunner";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.8/32"]; #Prefer 10.100.1.x ips for containers
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/media" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
      };
      "/run/secrets/github_runner1" = {
        isReadOnly = false;
        hostPath = "${config.age.secrets.github_runner1.path}";
      };
    };

    config = {pkgs, ...}: {
      imports = [
        # Covers some basic values, as well as fixing some potentially buggy networking issues
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ 80 ];
        };
      };
      services = {
        github-runners = {
          runner1 = {
            enable = true;
            name = "runner1";
            tokenFile = "/run/secrets/github_runner1";
            url = "https://github.com/faeranne/Trade-Station";
            nodeRuntimes = [
              "node20"
            ];
            extraLabels = [
              "nixos"
              "home"
            ];
          };
        };
      };
    };
  };
}
