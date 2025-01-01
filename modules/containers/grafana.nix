{
  self,
  config,
  lib,
  ...
}: let
  containerName = "grafana";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.16/32"];
    };
  };

  age.secrets.grafana_adminPass = {
    group = "container";
    owner = "container";
    mode = "770";
    generator = {
      script = "passphrase";
      tags = ["pregen"];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/grafana" = {
        isReadOnly = false;
        create = true;
        owner = "container:container";
      };
      "/run/secrets/adminPass" = {
        isReadOnly = true;
        hostPath = config.age.secrets.grafana_adminPass.path;
      };
    };

    specialArgs = {
      port = 5001;
    };

    config = let
      hostConfig = config;
    in {
      port,
      hostName,
      pkgs,
      ...
    }: {
      imports = [
        ./base.nix
        ./grafana/provision.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [port];
        };
      };
      services = {
        grafana = {
          enable = true;
          declarativePlugins = [
            pkgs.grafanaPlugins.yesoreyeram-infinity-datasource
          ];
          settings = {
            server = {
              domain = hostName;
              http_port = port;
              http_addr = "10.100.1.16";
              root_url = "https://${hostName}/";
            };
            security = {
              disable_initial_admin_creation = true;
              admin_user = "admin";
              admin_password = "$__file{/run/secrets/adminPass}";
            };
          };
        };
      };
      users.users.grafana.uid = lib.mkForce hostConfig.users.users.container.uid;
      users.groups.grafana.gid = lib.mkForce hostConfig.users.groups.container.gid;
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
