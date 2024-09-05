{self, config, lib, ...}:let
  containerName = "netbox";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.12/32"];
      peers = [
      ];
    };
  };

  age.secrets.netbox = {
    rekeyFile = self + "/secrets/containers/${containerName}/secret_key.age";
    generator.script = "alnum";
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/netbox" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/postgres" = {
        isReadOnly = false;
        create = true;
      };
      "/run/secrets/netbox" = {
        isReadOnly = true;
        hostPath = config.age.secrets.netbox.path;
      };
    };

    specialArgs = {
      port = 8096;
    };

    config = let
      hostConfig = config;
    in {port, ...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ port ];
        };
      };
      services = {
        inherit port;
        enable = true;
        secretKeyFile = "/run/secrets/netbox";
        listenAddress = lib.removeSuffix "/32" (lib.elemAt hostConfig.networking.wireguard.interfaces."wg${containerName}".ips 0);
      };
      users.users.netbox.uid = hostConfig.users.users.containers.uid;
      users.groups.netbox.gid = hostConfig.users.groups.containers.gid;
    };
  };

  # Setting up postgres user to match the nixos postgres user
  # that way if actual postgres is ever run on this system
  # (though it shouldn't, since we use containers for everything)
  # there will be no collision. as long as everything matche
  # it's ok to define something multiple times.
  users = {
    users.postgres = {
      uid = config.ids.uids.postgres;
      group = "postgres";
    };
    groups.postgres.gid = config.ids.gids.postgres;
  };
}
