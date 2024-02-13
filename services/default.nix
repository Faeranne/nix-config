{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./traefik.nix
    ./foundry.nix
    ./podman.nix
    ./ssh.nix
    ./minecraft.nix
    ./media
  ];
  options.custom.paths = with types; {
    vols = mkOption {
      type = str;
      description = "Container volume path.";
      default = "/persist/volumes";
    };
    media = mkOption {
      type = str;
      description = "Media Volume path.";
      default = "/persist/media";
    };
  };
}
