{ lib, ... }:
{
    imports = [
      ./options.nix
      ./base.nix
      ./disks.nix
      ./impermanence.nix
      ./users.nix
    ];
}
