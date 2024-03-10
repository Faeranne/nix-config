{
  description = "A very nixops flake";

  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    technitium = {
      url = "github:faeranne/nix-technitium";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: with builtins; let
    inherit (inputs.nixpkgs) lib;
    flakeLibs = import ./lib inputs;
    inherit (flakeLibs) mkHost;
    hostFolders = readDir ./hosts;
    hosts = foldl' (b: a: let
      include = if ((getAttr a hostFolders) == "directory") then [a] else [];
      res = b ++ include;
    in
      res
    ) [] (attrNames hostFolders);
  in {
    nixosConfigurations = listToAttrs (map (hostname: let
      res = mkHost hostname;
    in {
      name = hostname;
      value = lib.nixosSystem res.configuration;
    }) hosts );
    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = inputs.self;
      nodes = inputs.self.nixosConfigurations;
    };
  } // inputs.flake-utils.lib.eachDefaultSystem (system: rec {
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [ inputs.agenix-rekey.overlays.default ];
    };
    devShells.default = pkgs.mkShell {
      packages = [ pkgs.agenix-rekey ];
    };
  });
}
