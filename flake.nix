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
  };

  outputs = { self, nixpkgs, sops, disko, impermanence, ... }@inputs: {
    nixopsConfigurations.default = {
      inherit (inputs) nixpkgs;
      network.description = "Personal Servers";
      network.storage.legacy = {};
      network.enableRollback = true;
      hazel = { pkgs, ... }: {
        imports = [
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./hosts/hazel.nix
        ];
        deployment.targetHost = "192.168.1.101";
        deployment.targetUser = "nina";
      };
    };
    nixosConfigurations.hazel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./hosts/hazel.nix 
        ];
    };
  };
}
