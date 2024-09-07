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
            inherit (config.services.nextcloud.package.packages.apps) bookmarks calendar contacts cookbook cospend deck forms polls phonetrack memories maps notify_push richdocuments spreed tasks twofactor_nextcloud_notification twofactor_webauthn;
            pride_flags = pkgs.fetchNextcloudApp {
              url = "https://git.finally.coffee/finallycoffee/nextcloud-pride-flags/releases/download/1.1.0/pride_flags-1.1.0.tar.gz";
              sha256 = "sha256-zsfSFv6CBkblT17CIf8j+wjtVfvxDazXlQZBGyDO5xA=";
              license = "gpl3";
            };
            paperless = pkgs.fetchNextcloudApp {
              url = "https://github.com/nextcloud-releases/integration_paperless/releases/download/v1.0.3/integration_paperless-v1.0.3.tar.gz";
              sha256 = "sha256-3d3EgRCG4H5EcnQ3kmbVSEIsBNgrnuQA9pzdbiNtLyM=";
              license = "agpl3Only";
            };
            files_archive = pkgs.fetchNextcloudApp {
              url = "https://github.com/rotdrop/nextcloud-app-files-archive/releases/download/v1.2.3/files_archive.tar.gz";
              sha256 = "sha256-x7aXgahqlq8Z221iEG7lrfTpbiN5EwDLUHDxqSDpqtU=";
              license = "agpl3Only";
            };
            memegen = pkgs.fetchNextcloudApp {
              url = "https://github.com/nextcloud-releases/memegen/releases/download/v1.1.0/memegen-v1.1.0.tar.gz";
              sha256 = "sha256-M26J7udmkL95M1+TaLAdsO/qjg3bV+pluC+SNmxTE+8=";
              license = "agpl3Only";
            };
            secrets = pkgs.fetchNextcloudApp {
              url = "https://github.com/theCalcaholic/nextcloud-secrets/releases/download/v2.0.3/secrets.tar.gz";
              sha256 = "sha256-axIQet26lRAq3Ww8K8txKu6tB7kuWHilCcSLHZxq0Ug=";
              license = "agpl3Only";
            };
            guests = pkgs.fetchNextcloudApp {
              url = "https://github.com/nextcloud-releases/guests/releases/download/v3.1.0/guests-v3.1.0.tar.gz";
              sha256 = "sha256-YpJWOOP/45Lnw6XlQ6PLitG2NzSyYXCD5D9lZyn+mcQ=";
              license = "agpl3Only";
            };
            duplicate_finder = pkgs.fetchNextcloudApp {
              url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.2.5/duplicatefinder-v1.2.5.tar.gz";
              sha256 = "sha256-dnD+Qhxlz7RCOo3A1w6h+U0PVI1h4y+HRE/XwNsTxuk=";
              license = "agpl3Only";
            };
            recognize = pkgs.fetchNextcloudApp {
              url = "https://github.com/nextcloud/recognize/releases/download/v7.1.0/recognize-7.1.0.tar.gz";
              sha256 = "sha256-GPxEM2Lvy5VrF2acDvIJgf+fG9xEEsVNc1DR8Xh6zvY=";
              license = "agpl3Only";
            };
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
