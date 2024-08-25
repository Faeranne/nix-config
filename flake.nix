{
  description = "A very nixops flake";

  # Inputs are locked with flake.lock, to ensure versions match
  # then are fetched as per <name>.url and passed as a set to the
  # function `outputs` below.
  inputs = { 
    # This is the base nixpkgs repo.  Contains almost anything you could need.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    #nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    # Flake utils does some cool things with flakes. there's more 
    # details where they're used
    flake-utils.url = "github:numtide/flake-utils/main";
    # nixos-hardware contains defaults for a lot of well-known hardware
    # setups. we use it to get some defaults for the raspberry pi 4
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Impermanence allows us to use a default root directory that is
    # temporary.  On each reboot the / directory is fresh and setup from
    # scratch.  This helps prevent weird state from building up.
    impermanence.url = "github:nix-community/impermanence";
    # Ragenix is a `rage` based secret management tool.  More details 
    # are below in the `agenix-rekey` section of `outputs` below
    ragenix = {
      url = "github:yaxitech/ragenix";
      # `nixpkgs.follows` means that this input's input for nixpkgs will
      # match our lock file instead of theirs.  Means we only keep one copy
      # of nixpkgs that matches across the whole system, rather than a
      # different copy for each input flake.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # agenix-rekey used ragenix to automatically rekey secrets.
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Disko handles pre-paritioning systems during setup, as well as
    # providing the filesystem setup that is used during normal use.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # I run foundryvtt on a server, so this handles setting that up, since
    # it isn't in the official nixpkgs repo
    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Technitium is a graphical dns server that I use.
    technitium = {
      url = "github:faeranne/nix-technitium";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home manager can be use to handle your home dotfiles among other things.  I do a lot with this
    # so checkout the `./modules/homeManager` directory for more details.
    # This is also a well documented flake, so check out https://github.com/nix-community/home-manager
    # for more details
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # This generates pre-made nix disk images. I use it to build uefi install mediums with my
    # ssh public key baked-in, which makes fully headless setup possible.
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-docs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Stylix covers creating style files for quite a few programs, both at the system level
    # and as part of home-manager.  This covers things like terminal colors, sway styling,
    # waybar, and others.
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    # Yazi is a fancy terminal-based file manager. it supports image previews (using sixel),
    # and looks really cool while supporting many of the non-terminal file manager features.
    yazi = {
      url = "github:sxyazi/yazi";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nur = {
      url = "github:nix-community/NUR";
    };
  };

  # since `inputs` is a single variable here, it's the set of flakes input above.
  # this also includes this flake as `self`.
  outputs = {self, nixpkgs, agenix-rekey, nix-topology, ...}@inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];
    lib = import ./lib inputs;
  in {
    inherit lib;
    nixosConfigurations = import ./hosts inputs;
    # Agenix handles securing some secrets.  This can include passwords, authentication tokens
    # encryption key, etc.  It does so by using an age key who's public half is stored in
    # `./secrets/identities/`.  For me, that is `yubikey.nix` as I use a yubikey to store the
    # actual secret.  This requires some setup to work as per https://github.com/ryantm/agenix
    # and https://github.com/oddlama/agenix-rekey.  I recommend reading both for more details.
    agenix-rekey = agenix-rekey.configure {
      userFlake = self;
      nodes = self.nixosConfigurations;
    };

    # nixosModules makes the modules/nixos directory available to nixos builds.
    nixosModules = import ./modules/nixos;

    # Same but for homemanager modules
    homeModules = import ./modules/homeManager;

    containerModules = import ./modules/containers;

    userModules = import ./users;


    # This is for handling agenix rekey and generate commands
    devShells = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ 
          nix-topology.overlays.default
          (final: prev: {
            stable = import inputs.nixpkgs-stable {
              system = prev.system;
              config.allowUnfree = true;
            };
          })
          (final: prev: {
            pythonPackagesOverlays = prev.pythonPackagesOverlays ++ [
              (
                python-final: python-prev: {
                  diskinfo = self.nixosModules.python3.diskinfo;
                }
              )
            ];
          })
          inputs.agenix-rekey.overlays.default
        ];
      };
    in {
      default = pkgs.mkShell {
       shellHook = ''
         age-plugin-yubikey --identity > /tmp/yubikey.pub
       '';
       # there's a split here because the agenix-rekey package has the same name as the input,
       # so we have to manually call agenix-rekey from the pkgs set to prevent it from breaking.
       packages = (with pkgs; [ 
         age-plugin-yubikey
         age
         python3
       ]) ++ [
         pkgs.agenix-rekey 
       ];
      };
    });

    topology = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          nix-topology.overlays.default
        ];
      };
    in import nix-topology {
      inherit pkgs;
      modules = [
        ./modules/topology
        { nixosConfigurations = self.nixosConfigurations; }
      ];
    });

    # This imports everything from pkgs as usable commands.  Makes deploying easier,
    # while making things like generating tokens and keys easier to script
    legacyPackages = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.agenix-rekey.overlays.default
          nix-topology.overlays.default
          (final: prev: {
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (
                python-final: python-prev: {
                  diskinfo = self.legacyPackages.${system}.diskinfo;
                }
              )
            ];
          })
        ];
      };
    in {
      default = self.legacyPackages.${system}.deploy;
    } // pkgs.callPackages ./pkgs {inherit self inputs ;});
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
  };
}
