{config, myLib, ...}:let
  # Traefik is dependent on the host, so we're gonna make each traefik unique
  containerName = "traefik-${config.networking.hostName}";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.7/32"]; #Prefer 10.100.1.x ips for containers
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/freshrss" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
      };
      "/run/secrets/freshrss" = {
        hostPath = "${config.age.secrets.freshrss.path}";
        isReadOnly = false;
      };
    };

    specialArgs = {
      port = 80;
    };

    config = {hostName, port, lib, toForward, ...}: let
      containers = myLib.gatherContainers;
      services = lib.genAttrs toForward (serv: let 
        path = (lib.splitString "." serv); # path starts out as "container.service" getAttrFromPath requires it as a list.
        # this and set turn it into something getAttrFromPath expects ([ "container" "services" "service"]
        set = (builtins.elemAt path 0) ++ [ "services" ] ++ (builtins.elemAt path 1);
        ip = (lib.getAttrFromPath (builtins.elemAt path 0)).ip;
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
      services = {
        traefik.dynamicConfigOptions.http = {
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
          };
          services = builtins.mapAttrs (name: value: {
            loadBalancer.servers = [ {url = "http://${value.ip}:${toString value.port}"; } ];
          }) services;
        };
      };
    };
  };
}
