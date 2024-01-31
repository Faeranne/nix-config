{ ... }:
{
  imports = [
    ./dns.nix
    ./podman.nix
    ./ssh.nix
    ./traefik.nix
  ];
}
