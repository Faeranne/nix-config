{ config, lib, pkgs, ... }:
let
  elements = config.custom.elements;
in
{
  config = lib.mkIf (builtins.elem "server" elements) {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/containers"
      ];
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.oci-containers.backend = "podman";
  };
}

