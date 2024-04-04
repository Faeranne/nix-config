{ inputs, mkUser }: hostname: let
  systemConfig = { inherit hostname; } // import ../hosts/${hostname};
  system = import ./systemFromBase.nix systemConfig;
  hardware = import ./getHardware.nix systemConfig.elements;
  additionalModules = hardware ++ [ ../modules/nixos ../hosts/${hostname}/configuration.nix ];
in {
  configuration = {
    system = system;
    specialArgs = { 
      inherit inputs; 
      inherit (inputs) self;
      inherit systemConfig;
    };
    modules = additionalModules ++ [
      ({...}: {
        nixpkgs.overlays = [
          (final: prev: {
            stable = import inputs.nixpkgs-stable {
              system = prev.system;
              config.allowUnfree = true;
            };
          })
        ];
      })
    ];
  };
}
