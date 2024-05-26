inputs: rec 
{
  utils = import ./utils.nix;
  hosts = import ./hosts.nix inputs;
}
