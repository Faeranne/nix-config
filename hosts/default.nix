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
      ./sarah
      inputs.nix-topology.nixosModules.default
    ];
  };
  greg = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./greg
      inputs.nix-topology.nixosModules.default
    ];
  };
  laura = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./laura
      inputs.nix-topology.nixosModules.default
    ];
  };
  kyle = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./kyle
      inputs.nix-topology.nixosModules.default
    ];
  };
}
