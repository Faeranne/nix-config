{ inputs, mkUser }: hostname: let
  systemConfig = { inherit hostname; } // import ../hosts/${hostname};
  system = import ./systemFromBase.nix systemConfig;
  hardware = import ./getHardware.nix systemConfig.elements;
  additionalModules = systemConfig.modules ++ hardware ++ [ ../modules/nixos ];
in {
  configuration = {
    system = system;
    specialArgs = { 
      inherit inputs; 
      inherit (inputs) self;
      inherit systemConfig;
    };
    modules = additionalModules;
  };
}
