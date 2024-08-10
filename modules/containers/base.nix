{lib, ...}:{
  networking = {
    useHostResolvConf = lib.mkForce false;
  };

  services.resolved.enable = true;

  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.11";
}
