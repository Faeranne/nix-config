{inputs, lib, ...}:
let
  home-manager = inputs.home-manager;
  impermanence = inputs.impermanence;
in
{
  imports = [
#   (impermanence + "/home-manager.nix")
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.nina = import ./home.nix;
}
