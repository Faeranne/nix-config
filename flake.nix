{

  description = "A very nixops flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    sops = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, sops, disko, impermanence, foundryvtt, ... }@inputs: {
    nixosConfigurations.hazel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit foundryvtt; };
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          foundryvtt.nixosModules.foundryvtt
          ./hosts/hazel.nix 
          ({pkgs, ...}:{
            system.configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";
          })
        ];
    };
    nixosConfigurations.oracle1 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit foundryvtt; };
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./hosts/oracle1.nix 
          ({pkgs, ...}:{
            system.configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";
          })
        ];
    };
  };
}
