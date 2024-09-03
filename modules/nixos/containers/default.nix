{config, self, lib, ...}: {
  options = {
    containers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}:{
        options = {
          bindMounts = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule ({...}:{
              options = {
                create = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
                owner = lib.mkOption {
                  type = lib.types.str;
                  default = "root:root";
                };
              };
            }));
          };
        };
      }));
    };
  };
  config = let
    cfg = config.containers;
    foldPaths = lib.foldlAttrs (acc: _: value: let
      res = if (value.create) then [{
        inherit (value) owner;
        path = value.hostPath;
        permissions = "755";
      }] else [];
    in acc ++ res) [];
    createMounts = lib.foldlAttrs (acc: _: value: acc ++ (foldPaths value.bindMounts)) [] cfg;
  in {
    environment.createDir = createMounts;
    age.secrets = {
      "wghub" = {
        rekeyFile = self + "/secrets/containers/${config.networking.hostName}/wireguard-hub.age";
        group = "systemd-network";
        mode = "770";
        generator = {
          script = "wireguard";
          tags = [ "wireguard" ];
        };
      };
      "wggateway" = {
        rekeyFile = self + "/secrets/containers/${config.networking.hostName}/wireguard-gateway.age";
        group = "systemd-network";
        mode = "770";
        generator = {
          script = "wireguard";
          tags = [ "wireguard" ];
        };
      };
    };
    systemd.services = {
      "wireguard-wghub" = {
        bindsTo = ["netns@container.service"];
        after = ["netns@container.service"];
      };
      "wireguard-wggateway" = {
        bindsTo = ["netns@container.service"];
        after = ["netns@container.service"];
      };
    };

    networking = {
      firewall = {
        extraStopCommands = ''
          iptables -D FORWARD -i wggateway -o wggateway -j REJECT --reject-with icmp-admin-prohibited
        '';
        extraCommands = ''
          iptables -I FORWARD -i wggateway -o wggateway -j REJECT --reject-with icmp-admin-prohibited
        '';
      };

      wireguard.interfaces = {

        # Is used to join container wireguards between hosts
        "wghub" = {
          privateKeyFile = config.age.secrets."wghub".path;
          socketNamespace = "init";
          interfaceNamespace = "container";
        };

        # Allows local container wireguards to access the internet
        "wggateway" = {
          privateKeyFile = config.age.secrets."wggateway".path;
          listenPort = 51820;
          socketNamespace = "container";
          interfaceNamespace = "init";
        };
      };

      nat = {
        enable = true;
        internalInterfaces = [ "wggateway" ];
      };
    };
    users = {
      users.container = {
        isSystemUser = true;
        group = "container";
        uid = 997;
      };
      groups = {
        container = {
          gid = 997;
        };
        users = {
          members = [ "container" ];
        };
      };
    };
  };
}
