{lib, self, inputs, pkgs}: let 
  callPackage = lib.callPackageWith (pkgs // packages // {inherit self inputs;});
  packages = {
    generateUUID = callPackage ./generateUUID.nix {};
    #deploy = callPackage ./deploy.nix {};
    installSystem = callPackage ./installSystem.nix {};
    python3 = callPackage ./python3 {};
  };
in
  packages
