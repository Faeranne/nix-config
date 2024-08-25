inputs: let
  specialArgs = {
      inherit (inputs.self) nixosModules;
      inherit (inputs) self;
      inherit inputs;
  };
in rec {
  sarah = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./sarah
    ];
  };
  greg = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./greg
    ];
  };
  laura = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./laura
    ];
  };
  kyle = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./kyle
    ];
  };
}
