{
  inputs,
  ...
}:{
  imports = [
    ./nixconfig.nix
    ./options.nix
    ./age.nix
    ./networking-default.nix
    inputs.nix-topology.nixosModules.default
  ];
  system.stateVersion = "23.11";
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";
}
