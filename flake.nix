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
        inherit self;
      };
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          ./system
          ./system/intel.nix
          ./services/podman.nix
          ./services/ssh.nix
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
        inherit self;
      };
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
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
        inherit foundryvtt; 
        inherit technitium; 
        inherit self;
      };
      modules = 
        [ 
          disko.nixosModules.disko
          sops.nixosModules.sops
          impermanence.nixosModules.impermanence
          foundryvtt.nixosModules.foundryvtt
          technitium.nixosModules.technitium
          ./system
          ./system/oracle.nix
          ./services/podman.nix
          ./services/ssh.nix
          ./services/foundry-self.nix
          ./services/dns.nix
          ./services/traefik.nix 
          ./services/traefik/oracle1.nix 
          ({pkgs, ...}:{
            _module.args = {
              primaryEthernet = "eno1";
            };
            custom.elements = [ "oracle" ];
            custom.defaultDisk.rootDisk = "/dev/disk/by-path/pci-0000:00:13.0-ata-1";

            networking.hostName = "oracle1"; # Define your hostname.
            networking.hostId = "badc65d2";
          })
        ];
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
