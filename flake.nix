{
  description = "A very nixops flake";

  # Inputs are locked with flake.lock, to ensure versions match
  # then are fetched as per <name>.url and passed as a set to the
  # function `outputs` below.
  inputs = { 
    # This is the base nixpkgs repo.  Contains almost anything you
    # could need.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
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
      url = "github:nix-community/home-manager";
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
  };

  # since `inputs` is a single variable here, it's the set of flakes input above.
  # this also includes this flake as `self`.
  # `with builtins` makes all builtin functions available.
  #TODO: Don't do this! I think builtin's is only used in 2 or 3 places in this scope, so this
  #      is kinda dumb.
  #TODO: stop relying on inputs for *everything*. I've already swapped back to nixpkgs and self here
  #      but other variables should be broken back out too.
  outputs = {self, nixpkgs, ...}@inputs: with builtins; let
    # `nixpkgs.lib` is a pretty common set of libraries, so I usually include it
    # when making functions outside of nixos modules.
    #TODO: Look into using `callPackage` instead so lib can be used less. It's probably
    #      still gonna be needed here, but still should look into it (also for flakeLibs below)
    inherit (nixpkgs) lib;
    # flakeLibs hase `mkHost` and `mkUser` in it.  It needs `inputs` to do it's thing
    # so it's imported here.  I also inherit mkHost directly since I use it here.
    flakeLibs = import ./lib inputs;
    inherit (flakeLibs) mkHost mkUser utils;
    inherit (flakeLibs.utils) getFolders;
    # because forAllSystems uses some stuff from nixpkgs. should probably look into making it a
    # callPackage file instead.
    forAllSystems = flakeLibs.utils.forAllSystemsBuilder nixpkgs;
    hosts = getFolders ./hosts;
    #This closes the let enclosure on `outputs`
  in {
    # this produces a set containing every host as a `nixosSystem` derivation.
    # Usually you'll set this manually, but by doing it this way, I can iterate over
    # the hosts in `./hosts` automatically, making it easier to maintain.
    #TODO: I do this enough that maybe a `forEachHost` function is called for?
    nixosConfigurations = listToAttrs (map (hostname: let
      res = mkHost hostname;
      # simple let to make the results of `mkHost` easy to access
    in {
      # at this point `res` contains a single key `configuration`, which already includes
      # `inputs` and `inputs.self` in the module arguments, plus a special `systemConfig`
      # which is built from the `config.nix` in each host folder.
      # Check one of the `config.nix` files for more details.
      # Main thing is we now turn this into a nixosSystem derivation to be eventually built
      # by nixos-reload
      name = hostname;
      value = lib.nixosSystem res.configuration;
    }) hosts );
    # Agenix handles securing some secrets.  This can include passwords, authentication tokens
    # encryption key, etc.  It does so by using an age key who's public half is stored in
    # `./secrets/identities/`.  For me, that is `yubikey.nix` as I use a yubikey to store the
    # actual secret.  This requires some setup to work as per https://github.com/ryantm/agenix
    # and https://github.com/oddlama/agenix-rekey.  I recommend reading both for more details.
    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = inputs.self;
      nodes = inputs.self.nixosConfigurations;
    };

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [
        ./modules/droid
      ];
    };

    homeConfigurations = { 
      # standalone home-manager doesn't mix with nixos bakedin home-manager. gonna have to look into
      # systemless home-manager config.
      #"nina@sarah" = mkUser "sarah" "nina";
    };

    #TODO: This comment references the now unused forAllSystems from flake-utils.
    #      Need to change it to talk about the simpler way I use it now.
    # Packages and devShells require a set containing every system you might run this on.
    # to simplify this, since every system is compatable with these,
    # we use `forAllSystems` to make both contain a set with every system in it.
    # like `x86_64-linux` or `aarch64-linux`.  This does look a bit like magic since it will copy
    # `devShells.default` into `options.devShells.x86_64-linux.default` and so-on, but does make this
    # *much* easier to manage.
    packages = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.agenix-rekey.overlays.default
        ];
      };
    in {
      installer = inputs.nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        inherit pkgs;
        specialArgs = { 
          inherit (inputs) self;
        };
        modules = [
          ./modules/nixos/install.nix
        ];
        format = "install-iso";
      };
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
    } // foldl' (acc: host: 
      let
        config = utils.getHostConfig host;
        action = if self ? rev then "switch" else "test";
        message = if self ? rev then "Clean repo, full switch" else "Dirty repo, only testing";
        name = "deploy-${host}";
        value = pkgs.writeShellScriptBin "deploy-${host}" ''
          echo ${message}
          ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake .#${host} --target-host ${config.net.url} --use-remote-sudo ${action}
        '';
      in 
        # We only build a "deploy-host" program for hosts that have network configs already setup.
        # This should probably be altered to better blacklist desktop and laptop configs
        # since these will not have any way to remotely manage them.
        (if 
          builtins.hasAttr "net" config && builtins.hasAttr "url" config.net
        then
          {
            ${name} = value;
          }
        else
          {}
        ) //
        #This creates a `<system>-disko` script that formats drives for whatever system I may be installing.
        #Every ssytem is evaluated through this script.
        ##TODO: I also need to add something to pre-generate new local system keys.
        {
          "${host}-disko" = self.nixosConfigurations.${host}.config.system.build.diskoScript;
        } // acc
    ) {} hosts);
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
        ];
      };
    });
  };
  nixConfig = {
    extra-substituters = [ "https://yazi.cachix.org" ];
    extra-trusted-public-keys = [ "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k=" ];
  };
}
