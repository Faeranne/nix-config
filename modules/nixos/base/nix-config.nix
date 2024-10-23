# This file sets some nix configuration values.  these are used to manage
# the nix daemon and other features on this syste. often these affect
# nix.config directly
{self, inputs, ...}:{
  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
        "https://ncache.faeranne.com"
      ];
      trusted-public-keys = [
        "ncache.faeranne.com:f0zP4VrDZbT9A/Xx3tfLD9M9sI9maSvFJg3zbGh7Ty0=%"
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      # enables some commonly used experimental features
      # nix-command is the actual `nix` command, since that was introduced
      #   with flakes
      # flakes are the format I use for managing this system. specifically
      #   it enables things like `nix run` while using the `flake.nix` file
      #   in the root of this repo
      # ca-derivations is a new way to address derivations by what they contain
      #   instead of their build inputs.  In theory this will reduce rebuilding
      #   of some derivations by detecting that they will result in the same
      #   content, and just reusing the same derivation address.
      #   used in some nur stuff.
      experimental-features = [ "nix-command" "flakes" "ca-derivations"];
    };
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    # I was trying to setup github-tokens to allow additional nix flake update calls
    # but it didn't work right due to agenix not being correctly supported here.
    # TODO: readd when scalple is working
    extraOptions = ''
    '';
    # this controls the store garbage collection.  Mostly used to ensure
    # /nix/store doesn't ballon from being used a bunch and holding
    # really old nixos builds.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # see modules/nixos/base/security.nix for more details about this
  age = {
    secrets = {
      # this is the access tokens intended to be used with the above extraOptions field
      # its contents are manually managed since I don't get to make the keys themselves
      flake-accessTokens = {
        rekeyFile = self + "/secrets/accessTokens.age";
        mode = "770";
        group = "nixbld";
      };
    };
  };
}
