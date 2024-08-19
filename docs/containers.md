# System-NSpawn Containers

My setup opinionizes a few things about nix containers to make adding new ones relatively easy, while keeping
certain details around my security easier to manage

Things different from normal containers:
* Every container communicates with the outside world via a wireguard interface only.
* A given container can only be on one host at a time, but can be moved easily.

A new container can be created using the following template:
```nix
{self, myLib, pkgs, ...}:let
  containerName = "container-name";
  inherit (myLib) getWireguardHost;
  myHost = self.topology.${pkgs.system}.config.nodes.${containerName}.parent;
  mkPeer = myLib.mkPeer myHost;
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.5/32"]; #Prefer 10.100.1.x ips for containers
      listenPort = 51823; #listenPort must be globally unique.
      peers = [
        #See mkPeer below for more info
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/media" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
      };
    };

    config = {pkgs, ...}: {
      imports = [
        # Covers some basic values, as well as fixing some potentially buggy networking issues
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ 8096 ];
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

`mkGateway` is the same as `mkPeer`, but uses the target as a gateway for all traffic. make sure the target
is setup to handle that, or the container might not work.  If you do not set a `mkGateway`, the container will
not have access to the public internet at all.
