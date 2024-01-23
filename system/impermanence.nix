{ config, lib, pkgs, ... }:
{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/logs"
      "/etc/nixos"
      "/home"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
