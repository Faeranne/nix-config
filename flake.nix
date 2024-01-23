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
    nixinate.url = "github:matthewcroughan/nixinate";
  };

  outputs = { self, nixpkgs, sops, disko, impermanence, nixinate, ... }@inputs: {
    apps = nixinate.nixinate.x86_64-linux self;
    nixosConfigurations.hazel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./hosts/hazel.nix 
          ({pkgs, ...}:{
            system.configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";
            _module.args.nixinate = {
              host = "hazel.home.faeranne.com";
              sshUser = "nina";
              buildOn = "remote";
            };
          })
        ];
    };
  };
}
