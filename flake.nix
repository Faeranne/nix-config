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
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, impermanence, home-manager, ... }@inputs: {
    nixosConfigurations.hazel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs; 
        inherit self;
      };
      modules = 
        [ 
          inputs.disko.nixosModules.disko
          inputs.sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          ./system
          ./system/intel.nix
          ./services/podman.nix
          ./services/ssh.nix
          ./home
          ({...}:{
            _module.args = {
              primaryEthernet = "eno1";
            };
            custom.defaultDisk.rootDisk = "/dev/disk/by-path/pci-0000:00:17.0-ata-1";

            networking.hostName = "hazel"; # Define your hostname.
            networking.hostId = "279e089e";
          })
        ];
    };
    nixosConfigurations.bell = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs;
        inherit self;
      };
      modules = 
        [ 
          inputs.disko.nixosModules.disko
          inputs.sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./custom/nas_disk.nix
          ./system
          ./system/intel.nix
          ./services/podman.nix
          ./services/ssh.nix
          ({pkgs, ...}:{
            _module.args = {
              primaryEthernet = "eth0";
            };

            networking.hostName = "bell"; # Define your hostname.
            networking.hostId = "1cd0fa6c";
            custom.defaultDisk.enable = false;

            environment.systemPackages = with pkgs; [
              libgpiod
            ];
          })
        ];
    };
    nixosConfigurations.oracle1 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { 
        inherit inputs;
        inherit self;
      };
      modules = 
        [ 
          inputs.disko.nixosModules.disko
          inputs.sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./system
          ./system/oracle.nix
          ./services/podman.nix
          ./services/ssh.nix
          ./services
          ./services/dns.nix
          ./services/traefik.nix 
          ./services/traefik/oracle1.nix 
          ({pkgs, ...}:{
            _module.args = {
              primaryEthernet = "eno1";
            };
            custom.elements = [ "oracle" ];
            custom.defaultDisk.rootDisk = "/dev/disk/by-path/pci-0000:00:13.0-ata-1";
            custom.foundry.enable = true;
            custom.foundry.instances = {
              self = {
                host = "10.200.1.1";
                local = "10.200.1.2";
                url = "https://foundry.faeranne.com/";
              };
              neldu = {
                host = "10.200.1.5";
                local = "10.200.1.6";
                url = "https://vaneer.faeranne.com/";
              };
            };

            networking.hostName = "oracle1"; # Define your hostname.
            networking.hostId = "badc65d2";
          })
        ];
    };

    homeConfigurations."x86_64" = home-manager.lib.homeManagerConfiguration
    {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home/home.nix ];
    };

    homeConfigurations."aarch64" = home-manager.lib.homeManagerConfiguration
    {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      modules = [ ./home/home.nix ];
    };

    #Installer Images
    nixosConfigurations.anywhereIso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./system/install.nix
        ({ pkgs, ... }: {
          #sdImage.compressImage = false;
        })
      ];
    };
    nixosConfigurations.anywhereRpi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        ./system/install.nix
        ({ pkgs, ... }: {
          #sdImage.compressImage = false;
        })
      ];
    };
  };
}
