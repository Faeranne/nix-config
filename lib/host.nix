{ inputs, mkUser }: hostname: let
  base = import ../hosts/${hostname};
  system = import ./systemFromBase.nix base;
  hardware = import ./getHardware.nix base.elements;
  additionalModules = [
  ] ++ base.modules ++ hardware;
in {
  configuration = {
    system = system;
    specialArgs = { 
      inherit inputs; 
      inherit (inputs) self;
    };
    modules = [ 
      ../home
      ../system
      ../services
      (import ./hostModule.nix base hostname)
    ] ++ additionalModules;
  };
}
