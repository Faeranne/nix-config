{ config, lib, ... }:
let 
  cfg = config.custom.impermanence;
in
{
  options.custom.impermanence = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Whether to use impermanence";
    };
  };
  config = lib.mkIf cfg.enable {
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
  };
}
