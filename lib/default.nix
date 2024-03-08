inputs: rec 
{
  mkUser = import ./user.nix { inherit inputs; };
  mkHost = import ./host.nix { inherit inputs mkUser; };
  generateFlake = import ./flake.nix { inherit inputs mkUser mkHost; };
}
