{ config, lib, pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    #defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/containers"
    ];
  };
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
  };
  networking.firewall.trustedInterfaces = [ "podman0" ];
}

