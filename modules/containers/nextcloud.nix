{
  self,
  config,
  lib,
  ...
}: let
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
    in
      {
        config,
        hostName,
        port,
        pkgs,
        trustedProxy,
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
          nextcloud = {
            inherit hostName;
            enable = true;
            package = pkgs.nextcloud30;
            https = true;
            configureRedis = true;
            extraApps = {
              inherit (config.services.nextcloud.package.packages.apps) bookmarks calendar contacts cookbook cospend deck forms phonetrack memories maps notify_push richdocuments spreed tasks twofactor_webauthn;

              pride_flags = pkgs.fetchNextcloudApp {
                url = "https://git.finally.coffee/finallycoffee/nextcloud-pride-flags/releases/download/1.1.1/pride_flags-1.1.1.tar.gz";
                sha256 = "sha256-AC1DsCHzKVhXtYStSRBDFGgRHlK4WUegAJ5m5mr02yo=";
                license = "gpl3";
              };
              /*integration_paperless = pkgs.fetchNextcloudApp {
                url = "https://github.com/nextcloud-releases/integration_paperless/releases/download/v1.0.3/integration_paperless-v1.0.3.tar.gz";
                sha256 = "sha256-ARjs8cCUJICJaZiMIIt/lYk15WlXzzRqAQBWwax6HY4=";
                license = "agpl3Only";
              };*/
              files_archive = pkgs.fetchNextcloudApp {
                url = "https://github.com/rotdrop/nextcloud-app-files-archive/releases/download/v1.2.3/files_archive.tar.gz";
                sha256 = "sha256-D4D8OXlgF0Gv3NRSuq69Quu9jN96Blk0+QwiF1X63EU=";
                license = "agpl3Only";
              };
              memegen = pkgs.fetchNextcloudApp {
                url = "https://github.com/nextcloud-releases/memegen/releases/download/v1.1.0/memegen-v1.1.0.tar.gz";
                sha256 = "sha256-AuRZcyJcjlaGt/83+0BHqyN7tZwIvxQDUF3JqzSesk8=";
                license = "agpl3Only";
              };
              /*secrets = pkgs.fetchNextcloudApp {
                url = "https://github.com/theCalcaholic/nextcloud-secrets/releases/download/v2.0.3/secrets.tar.gz";
                sha256 = "sha256-6Q3j40EGENced4bKFAh1F63RVTk3gGHOmmaIX2ERj5c=";
                license = "agpl3Only";
              };*/
              guests = pkgs.fetchNextcloudApp {
                url = "https://github.com/nextcloud-releases/guests/releases/download/v4.0.1/guests-v4.0.1.tar.gz";
                sha256 = "sha256-rd1pVrlk2xZBxy4HZ0egew8SLAhcln/gSZ2Er5/FKtw=";
                license = "agpl3Only";
              };
              duplicatefinder = pkgs.fetchNextcloudApp {
                url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.2.9/duplicatefinder-v1.2.9.tar.gz";
                sha256 = "sha256-xDLDUGhjvGDMukXxhirocnDRnDu/R8BUOLUGquYbv1U=";
                license = "agpl3Only";
              };
              recognize = pkgs.fetchNextcloudApp {
                url = "https://github.com/nextcloud/recognize/releases/download/v7.1.0/recognize-7.1.0.tar.gz";
                sha256 = "sha256-qR4SrTHFAc4YWiZAsL94XcH4VZqYtkRLa0y+NdiFZus=";
                license = "agpl3Only";
              };
            };
            extraAppsEnable = true;
            config = {
              adminuser = "faeranne";
              adminpassFile = "/run/secrets/nextcloud_admin_pass";
            };
            settings = {
              trusted_proxies = [trustedProxy];
              default_phone_region = "US";
            };
            webfinger = true;
          };
          nginx = {
            enable = true;
            defaultListen = [
              {
                addr = lib.removeSuffix "/32" (lib.elemAt hostConfig.networking.wireguard.interfaces."wg${containerName}".ips 0);
                port = port;
              }
            ];
          };
        };
        users.users.nextcloud.uid = hostConfig.users.users.container.uid;
        users.groups.nextcloud.gid = hostConfig.users.groups.container.gid;
      };
  };
}
