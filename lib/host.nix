{ inputs, mkUser }: hostname: let
  base = import ../hosts/${hostname};
  system = import ./systemFromBase.nix base;
  additionalModules = [
  ] ++ base.modules;
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
    ] ++ additionalModules;
  };
}
