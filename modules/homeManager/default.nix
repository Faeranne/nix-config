{
  default = import ./base.nix;
  base = import ./base.nix;
  desktop = import ./desktop.nix;
  syncthing = import ./syncthing.nix;
}
