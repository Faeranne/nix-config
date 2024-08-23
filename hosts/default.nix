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
  /*
  gregTest = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./greg
      ./greg/testing.nix
      inputs.nix-topology.nixosModules.default
    ];
  };
  */
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
