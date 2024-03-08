{...}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    ./base.nix
    ./emulation.nix
    ./networking.nix
    ./programs.nix
    ./security.nix
    ./storage.nix
    ./user.nix
  ];
}
