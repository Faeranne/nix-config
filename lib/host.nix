{utils, inputs}: hostname: let
  containerGen = import ./container.nix;
  systemConfig = utils.getHostConfig hostname;
  system = import ./systemFromBase.nix systemConfig;
  hardware = import ./getHardware.nix systemConfig.elements;
  containersEnabled = (builtins.elem "containers" systemConfig.elements);
  containerConfigs = utils.getContainerConfigsForHost hostname;
  containerNames = builtins.attrNames containerConfigs;
  containerModules = if containersEnabled then (builtins.foldl' (acc: container: [
    (containerGen containerConfigs.${container})
  ]++acc) [] containerNames) else [];
  additionalModules = hardware ++ [ ../modules/nixos (utils.getHostModule hostname) ];
  allContainerConfigs = utils.allContainerConfigs;
in {
  configuration = {
    system = system;
    specialArgs = { 
      inherit inputs; 
      inherit (inputs) self;
      inherit systemConfig;
      containerConfigs = allContainerConfigs;
      flakeUtils = utils;
    };
    modules = additionalModules ++ containerModules ++ [
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
