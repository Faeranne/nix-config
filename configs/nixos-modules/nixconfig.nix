{
  inputs,
  ...
}: {
  imports = [
    ./nixpkgs.nix
    ./auto-update.nix
  ];
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
    };
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    extraOptions = ''
      connect-timeout = 5
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
