{
  config,
  lib,
  ...
}: let
  containerName = "hedgedoc";
  hostConfig = config;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.15/32"]; #Prefer 10.100.1.x ips for containers
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/storage" = {
        #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
        create = true;
      };
      "/run/secrets/hedgedoc" = {
        hostPath = "${config.age.secrets.hedgedoc.path}";
        isReadOnly = false;
      };
    };

    specialArgs = {
      port = 3000;
    };

    config = {
      hostName,
      port,
      ...
    }: {
      imports = [
        # Covers some basic values, as well as fixing some potentially buggy networking issues
        ./base.nix
      ];

      networking = {
        firewall = {
          # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [port];
        };
      };
      services.hedgedoc = {
        enable = true;
        settings = {
          domain = hostName;
          port = port;
          protocolUseSSL = true;
          allowAnonymous = false;
          allowFreeURL = true;
          requireFreeURLAuthentication = true;
          email = true;
          allowEmailRegister = false;
          db = {
            dialect = "sqlite";
            storage = "/storage/db.sqlite";
          };
        };
        environmentFile = "/run/secrets/hedgedoc";
      };
      users.users.hedgedoc.uid = lib.mkForce hostConfig.users.users.container.uid;
      users.groups.hedgedoc.gid = lib.mkForce hostConfig.users.groups.container.gid;
    };
  };
}
