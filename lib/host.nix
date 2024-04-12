{utils, inputs}: hostname: let
  systemConfig = utils.getHostConfig hostname;
  system = import ./systemFromBase.nix systemConfig;
  hardware = import ./getHardware.nix systemConfig.elements;
  additionalModules = hardware ++ [ ../modules/nixos (utils.getHostModule hostname) ];
in {
  configuration = {
    system = system;
    specialArgs = { 
      inherit inputs; 
      inherit (inputs) self;
      inherit systemConfig;
      flakeUtils = utils;
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
