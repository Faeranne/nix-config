{utils, inputs}: hostname: let
  #We import the container generation code here so we aren't re-importing it
  #multiple times for a single host.
  containerGen = import ./container.nix;
  systemConfig = utils.getHostConfig hostname;
  system = import ./systemFromBase.nix systemConfig;
  hardware = import ./getHardware.nix systemConfig.elements;
  containersEnabled = (builtins.elem "containers" systemConfig.elements);
  containerConfigs = utils.getContainerConfigsForHost hostname;
  containerNames = builtins.attrNames containerConfigs;
  #note that thanks to lazy evaluation, none of the containerGen runs unless
  #"containers" is part of the elements list.
  #But we do still verify `containers.json` is valid below.
  containerModules = if containersEnabled then (builtins.foldl' (acc: container: [
    (containerGen containerConfigs.${container})
  ]++acc) [] containerNames) else [];
  additionalModules = hardware ++ [ ../modules/nixos (utils.getHostModule hostname) ];
  #Since this is eventually referenced below, this will
  #cause `containers.json` to be validated if *any* of the defined containers
  #are referenced *anywhere*.
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
      inputs.stylix.nixosModules.stylix
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
