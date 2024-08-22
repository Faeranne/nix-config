# System-NSpawn Containers

My setup opinionizes a few things about nix containers to make adding new ones relatively easy, while keeping
certain details around my security easier to manage

Things different from normal containers:
* Every container communicates with the outside world via a wireguard interface only.
* A given container can only be on one host at a time, but can be moved easily.

A new container can be created using the following template:
```nix
{self, config, myLib, pkgs, ...}:let
  containerName = "<containername>";
  myHost = self.topology.${pkgs.system}.config.nodes.${containerName}.parent;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.x/32"]; #Prefer 10.100.1.x ips for containers
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/var/lib/service" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
      };
      #Secrets should be added with hostPath here.
      "/run/secrets/freshrss" = {
        hostPath = "${config.age.secrets.freshrss.path}";
        isReadOnly = false;
      };
    };

    specialArgs = {
      # set `port` to be the outbound port of whatever service is used here
      port = 80;
      # or use `ports` to set multiple service ports
      #ports = { someService = 81 };
      # Don't set both
    };

    config = {hostName, port, lib, toForward, ...}: {
      # hostName is the fully qualified hostName associated with this contianer
      # hostNames is the same but as a set of services `{ someService = "host.domain.tld"; }`
      # port(s) is as above.
      imports = [
        # Covers some basic values, as well as fixing some potentially buggy networking issues
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ port ];
          #allowedTCPPorts = builtins.attrValues ports; #This gets all the ports defined, rather than a single;
        };
      };
    };
  };
}
```

## `mkPeer` & `mkGateway`

`mkPeer` is a helper function that generates expected wireguard `peers` entries.  
This function accepts 2 values, the host of the interface being added to, and the second is the name of the
interface to add.  This automatically searches all configs for the target interface using `getWireguardHost`.

`mkGateway` is the same as `mkPeer`, but sets up the container's host wireguard as the outbound gateway.
This function only accepts the host of the container as a value.
