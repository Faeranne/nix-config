{
  description = "A very nixops flake";

  # Inputs are locked with flake.lock, to ensure versions match
  # then are fetched as per <name>.url and passed as a set to the
  # function `outputs` below.
  inputs = { 
    # This is the base nixpkgs repo.  Contains almost anything you
    # could need.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    # are below
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
    # Home manager can be use to handle your home dotfiles.  I do a lot with this
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
  };

  # since `inputs` is a single variable here, it's the set of flakes input above.
  # this also includes this flake as `self`.
  # `with builtins` makes all builtin functions available.
  outputs = inputs: with builtins; let
    # `nixpkgs.lib` is a pretty common set of libraries, so I usually include it
    # when making functions outside of nixos modules.
    inherit (inputs.nixpkgs) lib;
    # flakeLibs hase `mkHost` and `mkUser` in it.  It needs `inputs` to do it's thing
    # so it's imported here.  I also inherit mkHost directly since I use it here.
    flakeLibs = import ./lib inputs;
    inherit (flakeLibs) mkHost;
    # `readDir` is a builtin.  This returns every filename inside the passed path.
    # and sets it's value to either "regular", "directory", "symlink", or "unknown".
    # The goal here is to get only directories, so the below `foldl'` function
    # turns `hostFolders` into a list containing the names of the directories in
    # `./hosts`
    hostFolders = readDir ./hosts;
    hosts = foldl' (b: a: let
      include = if ((getAttr a hostFolders) == "directory") then [a] else [];
      res = b ++ include;
      #this closes the let enclosure on `foldl'`'s first paramenter
    in
      res
      # we also have to pass an empty array as an initial value for foldl' to work with,
      # as well as the list to fold. In this case, I use `attrNames`, another builtin,
      # to get all the key names from `hostFolders`
    ) [] (attrNames hostFolders);
    #This closes the let enclosure on `outputs`
  in {
    # this produces a set containing every host as a `nixosSystem` derivation.
    # Usually you'll set this manually, but by doing it this way, I can iterate over
    # the hosts in `./hosts` automatically, making it easier to maintain.
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
  } // inputs.flake-utils.lib.eachDefaultSystem (system: rec {
    # `outputs.devShells` requires a set containing every system you might run this on.
    # to simplify this, since every system is compatable with the devshell I'm making,
    # we just use `eachDefaultSystem` to make devShells contain a set with every system in it.
    # like `x86_64-linux` or `aarch64-linux`.  This does look a bit like magic since it will copy
    # `devShells.default` into `options.devShells.x86_64-linux.default` and so-on, but does make this
    # *much* easier to manage.
    pkgs = import inputs.nixpkgs {
      inherit system;
      # I still don't quite understand overlays, so I'll just say this is from agenix-rekey.
      # I'll add more notes here when I do understand it fully.
      overlays = [ inputs.agenix-rekey.overlays.default ];
    };
    devShells.default = pkgs.mkShell {
      # We're including the agenix-rekey binary `agenix` in our devshell.  This allows for rekeying secrets
      # using `agenix edit <secret>` from within the devshell.
      packages = with pkgs; [ 
        agenix-rekey 
        age
      ];
    };
  });
}
