{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    ./base.nix
    ./disks.nix
    ./impermanence.nix
    ./users.nix
    ./networks.nix
    ./packages.nix
    ./desktop.nix
    ./gpu.nix
    ./games.nix
  ];
}
