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
    generator.script = {pkgs, file, ...}:''
      ${pkgs.pwgen}/bin/pwgen 50 1 -ys1nc
    '';
    mode = "550";
    owner = "container";
    group = "container";
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/netbox" = {
        isReadOnly = false;
        create = true;
        owner = "container:container";
      };
      "/var/lib/postgres" = {
        isReadOnly = false;
        create = true;
        owner = "postgres:postgres";
      };
      "/run/secrets/netbox" = {
        isReadOnly = true;
        hostPath = config.age.secrets.netbox.path;
      };
    };

    specialArgs = {
      port = 8096;
    };

    # Initial startup from a fresh container can take an extended amount of time
    timeoutStartSec = "5min";

    config = let
      hostConfig = config;
    in {port, pkgs, ...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ port ];
        };
      };
      services = {
        postgresql = {
          dataDir = "/var/lib/postgres";
          package = pkgs.postgresql_15;
        };
        netbox = {
          enable = true;
          port = 8001;
          package = pkgs.netbox;
          secretKeyFile = "/run/secrets/netbox";
          listenAddress = "127.0.0.1";
          settings = {
            ALLOWED_HOSTS = [ "netbox.faeranne.com" ];
            CSRF_TRUSTED_ORIGINS = [ "https://netbox.faeranne.com" ];
          };
        };
        nginx = {
          enable = true;
          user = "netbox"; # otherwise nginx cant access netbox files
          recommendedProxySettings = true; # otherwise you will get CSRF error while login
          defaultListen = [{
           addr = (lib.removeSuffix "/32" (lib.elemAt hostConfig.networking.wireguard.interfaces."wg${containerName}".ips 0));
           port = port;
          }];
          virtualHosts.default = {
            default = true;
            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:8001";
              };
              "/static/" = { alias = "${config.services.netbox.dataDir}/static/"; };
            };
          };
        };
      };
      users.users.netbox.uid = hostConfig.users.users.container.uid;
      users.groups.netbox.gid = hostConfig.users.groups.container.gid;
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
