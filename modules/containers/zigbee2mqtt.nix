{config, ...}:let
  containerName = "zigbee";
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
      "/run/secrets/paperless_superuser" = {
        isReadOnly = false;
        hostPath = "${config.age.secrets.paperless_superuser.path}";
      };
    };

    specialArgs = {
      port = 8080;
    };

    config = {config, hostName, port, ...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ config.services.paperless.port ];
        };
      };
      services = {
        zigbee2mqtt = {
          enable = true;
          settings = {
            permit_join = true;
            serial = {
              port = "/dev/ttyZigbee";
            };
            mqtt = {
              server = "";
              base_topic = "";
              client_id = "";
            };
            frontend = {
              port = port;
              host = 0.0.0.0;
              auth_token = "";
              url = "https://${hostName}";
            };
            devices = {
              "0x000b5200000003ad" = {
                friendly_name = "Computer Power";
                retain = false;
                disabled = false;
                homeassistant = null;
              };
            };
          };
        };
      };
    };
  };
}
