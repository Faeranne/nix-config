{self, config, lib, ...}:let
  containerName = "nextcloud";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.13/32"];
      peers = [
      ];
    };
  };

  age.secrets.nextcloud_admin_pass = {
    rekeyFile = self + "/secrets/containers/${containerName}/admin_pass.age";
    generator.script = "passphrase";
    mode = "550";
    owner = "container";
    group = "container";
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/nextcloud" = {
        isReadOnly = false;
        create = true;
        owner = "container:container";
      };
      "/run/secrets/nextcloud_admin_pass" = {
        isReadOnly = true;
        hostPath = config.age.secrets.nextcloud_admin_pass.path;
      };
    };

    specialArgs = {
      port = 8096;
    };

    config = let
      hostConfig = config;
    in {config, hostName, port, pkgs, trustedProxy, ...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ port ];
        };
      };
      services = {
        nextcloud = {
          inherit hostName;
          enable = true;
          package = pkgs.nextcloud29;
          https = true;
          configureRedis = true;
          extraApps = {
            inherit (config.services.nextcloud.package.packages.apps) bookmarks calendar contacts spreed tasks twofactor_nextcloud_notification twofactor_webauthn;
          };
          extraAppsEnable = true;
          config = {
            adminuser = "faeranne";
            adminpassFile = "/run/secrets/nextcloud_admin_pass";
          };
          settings = {
            trusted_proxies = [ trustedProxy ];
            default_phone_region = "US";
          };
          webfinger = true;
        };
        nginx = {
          enable = true;
          defaultListen = [{
           addr = (lib.removeSuffix "/32" (lib.elemAt hostConfig.networking.wireguard.interfaces."wg${containerName}".ips 0));
           port = port;
          }];
        };
      };
      users.users.nextcloud.uid = hostConfig.users.users.container.uid;
      users.groups.nextcloud.gid = hostConfig.users.groups.container.gid;
    };
  };
}
