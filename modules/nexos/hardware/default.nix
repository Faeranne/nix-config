{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption;
  inherit (lib.types) submodule;
in {
  options = {
    nexos = {
      hardware = mkOption {
        description = "Hardware configuration options for NexOS";
        type = submodule {
          options = {
          };
        };
      };
    };
  };

  imports = [
    ./cpu.nix
    ./gpu.nix
  ];
}
