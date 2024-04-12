inputs: rec 
{
  utils = import ./utils;
  mkHost = import ./host.nix { inherit utils inputs; };
  mkUser = import ./home.nix { inherit utils inputs; };
}
