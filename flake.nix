{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
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
        flake-utils.follows = "flake-utils";
      };
    };
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    extra-container = {
      url = "github:erikarvstedt/extra-container";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
        inputs.ez-configs.flakeModule
        ./flake-module.nix
      ];
      ezConfigs = {
        root = ./configs;
        globalArgs = {
          inherit inputs;
        };
      };
      flake = {
      };
      systems = [
        "x86_64-linux"
      ];
      perSystem = { config, pkgs, ...}: {
        topology.modules = [
        ];
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ config.agenix-rekey.package ];
        };
      };
    }
  );
}
