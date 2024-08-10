inputs: let
  specialArgs = {
      inherit (inputs.self) nixosModules;
      inherit (inputs) self;
      inherit inputs;
  };
in {
  sarah = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./hosts/sarah
    ];
  };
  greg = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./hosts/greg
    ];
  };
  laura = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./hosts/laura
    ];
  };
}
