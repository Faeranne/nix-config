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
    technitium = {
      url = "github:faeranne/nix-technitium";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, sops, disko, impermanence, foundryvtt, technitium, ... }@inputs: {
    nixosConfigurations.hazel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit foundryvtt; 
        inherit technitium; 
      };
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./system/disks.nix
          ./system/base.nix
          ./system/intel.nix
          ./services/podman.nix
          ./services/ssh.nix
          ({...}:{
            _module.args = {
              rootDisk = "/dev/disk/by-path/pci-0000:00:17.0-ata-1";
              primaryEthernet = "eno1";
            };

            networking.hostName = "hazel"; # Define your hostname.
            networking.hostId = "279e089e";
          })
        ];
    };
    nixosConfigurations.oracle1 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { 
        inherit foundryvtt; 
        inherit technitium; 
      };
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          foundryvtt.nixosModules.foundryvtt
          technitium.nixosModules.technitium
          ./system/disks.nix
          ./system/base.nix
          ./system/intel.nix
          ./services/podman.nix
          ./services/ssh.nix
          ./traefik/oracle1.nix 
          ({...}:{
            _module.args = {
              rootDisk = "/dev/disk/by-path/pci-0000:00:17.0-ata-1";
              primaryEthernet = "eno1";
            };

            networking.hostName = "oracle1"; # Define your hostname.
            networking.hostId = "badc65d2";
          })
        ];
    };
  };
}
