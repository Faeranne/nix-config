{ pkgs, inputs, ... }:
{
  imports = [
    ./system/programs.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  system = {
    stateVersion = "23.11"; # Did you read the comment?
  };
  home-manager.config = ./home/droid.nix;
}
