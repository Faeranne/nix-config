inputs: let
  utils = import ./.;
in rec {
  generateAllHosts = builtins.listToAttrs (map (hostname: let
    res = generateHost hostname;
    # simple let to make the results of `mkHost` easy to access
  in {
    # at this point `res` contains a single key `configuration`, which already includes
    # `inputs` and `inputs.self` in the module arguments, plus a special `systemConfig`
    # which is built from the `config.nix` in each host folder.
    # Check one of the `config.nix` files for more details.
    # Main thing is we now turn this into a nixosSystem derivation to be eventually built
    # by nixos-reload
    name = hostname;
    value = lib.nixosSystem res.configuration;
  }) utils.allHosts );
  generateHost = {host, pkgs}: let
    #We import the container generation code here so we aren't re-importing it
    #multiple times for a single host.
    containerGen = import ../container.nix;
    systemConfig = utils.getHostConfig hostname;
    system = import ../systemFromBase.nix systemConfig;
    hardware = import ../getHardware.nix systemConfig.elements;
    containersEnabled = (builtins.elem "containers" systemConfig.elements);
    containerConfigs = utils.getContainerConfigsForHost hostname;
    containerNames = builtins.attrNames containerConfigs;
    #note that thanks to lazy evaluation, none of the containerGen runs unless
    #"containers" is part of the elements list.
    #But we do still verify `containers.json` is valid below.
    containerModules = if containersEnabled then (builtins.foldl' (acc: container: [
      (containerGen containerConfigs.${container})
    ]++acc) [] containerNames) else [];
    additionalModules = hardware ++ [ ../../modules/nixos (utils.getHostModule hostname) ];
    #Since this is eventually referenced below, this will
    #cause `containers.json` to be validated if *any* of the defined containers
    #are referenced *anywhere*.
    allContainerConfigs = utils.allContainerConfigs;
  in pkgs.lib.nixosSystem {
    system = system;
    specialArgs = { 
      inherit inputs; 
      inherit (inputs) self;
      inherit systemConfig;
      containerConfigs = allContainerConfigs;
      flakeUtils = utils;
    };
    modules = additionalModules ++ containerModules ++ [
    ];
  };
  generateContainer = import ./container.nix;
}
