{
  self,
  config,
  lib,
  ...
}: let
  containerName = "whiteborhir";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.15/32"];
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/whitebophir" = {
        isReadOnly = false;
        create = true;
        owner = "container:container";
      };
    };

    specialArgs = {
      port = 5001;
    };

    config = let
      hostConfig = config;
    in {
      port,
      pkgs,
      ...
    }: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [port];
        };
      };
      services = {
        services.whitebophir = {
          enable = true;
          port = port;
        };
      };
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
