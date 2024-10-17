{config, myLib, ...}:let
  # Traefik is dependent on the host, so we're gonna make each traefik unique
  containerName = "traefik${config.networking.hostName}";
  hostConfig = config;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/etc/traefik" = {
        isReadOnly = false;
        create = true;
        owner = "container:container";
      };
    };

    specialArgs = {
      port = 80;
      extraRouters = {
      };
      extraServices = {
      };
      toForward = [
      ];
    };

    config = {hostName, port, lib, toForward, extraServices, extraRouters, ...}: let
      containers = myLib.gatherContainers;
      services = lib.genAttrs toForward (serv: let 
        path = (lib.splitString "."  serv); # path starts out as "container.service" getAttrFromPath requires it as a list.
        # this and set turn it into something getAttrFromPath expects ([ "container" "services" "service"]
        set = [(builtins.elemAt path 0)] ++ [ "services" ] ++ [(builtins.elemAt path 1)];
        ip = (lib.getAttrFromPath [(builtins.elemAt path 0)] containers).ip;
        service = lib.getAttrFromPath set containers;
      in {
        inherit ip;
        inherit (service) hostName port;
      });
    in {
      imports = [
        # Covers some basic values, as well as fixing some potentially buggy networking issues
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ port ];
        };
      };
      systemd = {
        services = {
          traefik = {
            enable = true;
            serviceConfig = {
              # Normal 64 limit causes a 203 error in systemd.
              # Possibly a conflict between traefik and containerization
              LimitNPROC = lib.mkForce 128;
            };
          };
        };
      };
      services = {
        traefik = {
          enable = true;
          dataDir = "/etc/traefik";
          staticConfigOptions = {
            entryPoints = {
              internal.address = "127.0.0.1:81";
              web = {
                address = ":${toString port}";
                http.redirections.entryPoint = {
                  to = "websecure";
                  scheme = "https";
                };
              };
              websecure = {
                address = ":443";
                http.tls.certResolver = "leresolver";
              };
            };
            certificatesresolvers.leresolver.acme = {
              email = "system@projectmakeit.com";
              storage = "/etc/traefik/acme.json";
              httpchallenge.entrypoint = "web";
            };
            api.dashboard = true;
            ping.entrypoint = "internal";
          };
          dynamicConfigOptions.http = {
            routers = (builtins.mapAttrs (name: value: {
              rule = "Host(`${value.hostName}`)";
              service = name;
              entryPoints = [ "websecure" ];
            }) services) // {
              dashboard = {
                rule = "Host(`${hostName}`)";
                service = "api@internal";
                entryPoints = [ "websecure" ];
              };
            } // extraRouters;
            services = (builtins.mapAttrs (name: value: {
              loadBalancer.servers = [ {url = "http://${value.ip}:${toString value.port}"; } ];
            }) services) // extraServices;
          };
        };
      };
      users.users.traefik.uid = hostConfig.users.users.container.uid;
      users.groups.traefik.gid = hostConfig.users.groups.container.gid;
    };
  };
}
