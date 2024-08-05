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
  };

  # since `inputs` is a single variable here, it's the set of flakes input above.
  # this also includes this flake as `self`.
  # `with builtins` makes all builtin functions available.
  #TODO: Don't do this! I think builtin's is only used in 2 or 3 places in this scope, so this
  #      is kinda dumb.
  #TODO: stop relying on inputs for *everything*. I've already swapped back to nixpkgs and self here
  #      but other variables should be broken back out too.
  outputs = {self, nixpkgs, ...}@inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in {
    nixosConfigurations = {
      sarah = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit (self) nixosModules;
          inherit self inputs;
        };
        modules = [
          ./hosts/sarah
        ];
      };
    };
    # Agenix handles securing some secrets.  This can include passwords, authentication tokens
    # encryption key, etc.  It does so by using an age key who's public half is stored in
    # `./secrets/identities/`.  For me, that is `yubikey.nix` as I use a yubikey to store the
    # actual secret.  This requires some setup to work as per https://github.com/ryantm/agenix
    # and https://github.com/oddlama/agenix-rekey.  I recommend reading both for more details.
    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = inputs.self;
      nodes = inputs.self.nixosConfigurations;
    };

    nixosModules = import ./modules/nixos;

    homeManagerModules = import ./modules/homeManager;

    containerModules = import ./modules/containers;

    userModules = import ./users;

    devShells = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ 
          (final: prev: {
            stable = import inputs.nixpkgs-stable {
              system = prev.system;
              config.allowUnfree = true;
            };
          })
          inputs.agenix-rekey.overlays.default
        ];
      };
    in {
      default = pkgs.mkShell {
       shellHook = ''
         age-plugin-yubikey --identity > /tmp/yubikey.pub
       '';
        #NOTE: we're using the stable version for the moment till nixos/nixpkgs#309297
        # is merged.  libpcsclite is broken in the current unstable.
        packages = with pkgs; [ 
         agenix-rekey 
         age-plugin-yubikey
         age
         python3
        ];
      };
    });
    packages = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.agenix-rekey.overlays.default
        ];
      };
    in {
      # This allows me to run `nix run .#deploy` and get an appropriate nixos-rebuild call with
      # minimal fuss.
      deploy = let
        # If we're on a clean repo (everything is commited and no untracked files exist), then we
        # do the full nixos-rebuild, including setting up the boot requirements.
        # If it's still dirty, we just do a test, which will revert on reboot.
        action = if self ? rev then "switch" else "test";
        # I include a message to let myself know if things are being setup for boot or not.
        message = if self ? rev then "Clean repo, full switch" else "Dirty repo, only testing";
      in pkgs.writeShellScriptBin "deploy" ''
        echo ${message}
        # nettools/hostname grabs the hostname of the current system. We do this here instead of in
        # the flake.nix because we can't introduce impurity at that stage.  Techinically it should always
        # be the same regardless, since we never push this script to any other system, but you never know,
        # and Nix really does care.
        sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake .#`${pkgs.nettools}/bin/hostname` ${action}
      '';
      default = inputs.self.packages.${system}.deploy;
    });
  };
}
