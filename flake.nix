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
    nixosConfigurations.greg = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs; 
        inherit self;
      };
      modules = 
        [ 
          ./home
          ./system
          ./services
          ./hardware/intel.nix
          ({...}:{
            networking.hostName = "greg"; # Define your hostname.
            networking.hostId = "ccd933cc";

            boot.zfs.extraPools = [ "Storage" ];

            custom = {
              elements = [ "intel" "server" "media" ];
              primaryNetwork = "eno1";
              defaultDisk.rootDisk = "/dev/disk/by-path/pci-0000:00:1a.0-usb-0:1.1:1.0-scsi-0:0:0:0";
              baseURL = "home.faeranne.com";
              traefik.enable = true;
              paths = {
                vols = "/Storage/volumes";
                media = "/Storage/media";
              };
              jelly = {
                local = "10.200.1.3";
                url = "tv.faeranne.com";
              };
              servarr = {
                local = "10.200.1.4";
                baseUrl = "faeranne.com";
              };
              tor = {
                local = "10.88.1.2";
              };
            };
          })
        ];
    };
    nixosConfigurations.hazel = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs; 
        inherit self;
      };
      modules = 
        [ 
          ./home
          ./system
          ./services
          ./hardware/intel.nix
          ({...}:{
            networking.hostName = "hazel"; # Define your hostname.
            networking.hostId = "279e089e";

            custom = {
              elements = [ "intel" "server" ];
              primaryNetwork = "eno1";
              defaultDisk.rootDisk = "/dev/disk/by-path/pci-0000:00:17.0-ata-1";
              minecraft = {
                enable = true;
                router.local = "10.88.1.2";
                instances = {
                  cozy1 = {
                    local = "10.88.1.3";
                    domain = "cozy.faeranne.com";
                    size = "4g";
                    motd = "Cozy Craft 2.0";
                    pack = "https://raw.githubusercontent.com/Faeranne/cozy-pack/master/pack.toml";
                    eula = "true";
                    rcon_path = "rcon/cozy";
                  };
                };
              };
            };
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
          ./home
          ./system
          ./services
          ./hardware/intel.nix
          ./custom/nas_disk.nix
          ({pkgs, ...}:{
            networking.hostName = "bell"; # Define your hostname.
            networking.hostId = "1cd0fa6c";

            custom = {
              elements = [ "intel" "server" ];
              primaryNetwork = "eth0";
              defaultDisk.enable = false;
            };

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
      modules = [ 
        ./home
        ./system
        ./services
        ./hardware/oracle.nix
        ({pkgs, ...}:{
          networking.hostName = "oracle1"; # Define your hostname.
          networking.hostId = "badc65d2";

          custom = {
            elements = [ "oracle" "server" ];
            primaryNetwork = "enp0s6";
            defaultDisk.rootDisk = "/dev/disk/by-path/pci-0000:18:00.0-scsi-0:0:0:1";
            traefik.enable = true;
            baseURL = "oracle1.faeranne.com";
            foundry = {
              enable = true;
              instances = {
                self = {
                  local = "10.200.1.5";
                  url = "foundry.faeranne.com";
                };
                neldu = {
                  local = "10.200.1.6";
                  url = "vaneer.faeranne.com";
                };
              };
            };
          };
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
