{inputs, modules ? []}: let
  lib = inputs.nixpkgs.lib;
  specialArgs = {
    inherit (inputs.self) nixosModules;
    inherit (inputs) self;
    inherit inputs;
  };
  hosts = let
    folders = builtins.readDir ./.;
  in
    builtins.attrNames (lib.filterAttrs (name: type: type == "directory") folders);
  hostConfigs = lib.genAttrs hosts (host:
    lib.nixosSystem {
      inherit specialArgs;
      modules = modules ++ [
        ./${host}
      ];
    });
in
  hostConfigs
