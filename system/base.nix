{ config, self, lib, inputs, ... }:
let
  sops = inputs.sops;
in
{
  options.custom = {
    elements = lib.mkOption {
      default = [];
      description = "Whether to enable the default disk layout";
      type = lib.types.listOf lib.types.str;
    };
  };
  config = {
    system = {
      configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";
      stateVersion = "23.11"; # Did you read the comment?
    };
    
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    time.timeZone = "America/Indiana";
    i18n.defaultLocale = "en_US.UTF-8";

    sops.age.keyFile = if config.custom.impermanence.enable then "/persist/sops.key" else "/nix/sops.key";
  };
}
