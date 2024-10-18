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
  hazel = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./hazel
    ];
  };
  greg = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./greg
    ];
  };
  test = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./test
    ];
  };
}
