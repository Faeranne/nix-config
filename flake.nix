{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs = inputs@{flake-parts, ...}:(
    flake-parts.lib.mkFlake {
      inherit inputs;
    } {
      imports = [
        inputs.agenix-rekey.flakeModule
        inputs.nix-topology.flakeModule
      ];
      flake = {
      };
      systems = [
        "x86_64-linux"
      ];
      perSystem = { config, pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ config.agenix-rekey.package ];
        };
      };
    }
  );
}
