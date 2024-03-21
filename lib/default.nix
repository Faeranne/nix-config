inputs: rec 
{
  mkUser = import ./user.nix { inherit inputs; };
  mkHost = import ./host.nix { inherit inputs mkUser; };
  utils = import ./utils;
}
