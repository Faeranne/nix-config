{ pkgs, inputs, ... }:
{
  environment.packages = [ pkgs.vim ];
  system.stateVersion = "23.11";
  home-manager.config = ./home/droid.nix;
}
