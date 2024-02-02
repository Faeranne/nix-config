{ ... }:
{
  imports = [
    ./traefik.nix
    ./foundry.nix
    ./podman.nix
    ./ssh.nix
  ];
}
