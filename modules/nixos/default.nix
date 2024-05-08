{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-generators.nixosModules.all-formats
    inputs.home-manager.nixosModules.home-manager
    inputs.ragenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    ./base.nix
    ./graphical.nix
    ./emulation.nix
    ./networking.nix
    ./programs.nix
    ./security.nix
    ./storage.nix
    ./user.nix
    ./rgb.nix
    ./printers.nix
    ./traefik.nix
    ./containers.nix
    ./servers.nix
  ];
}
