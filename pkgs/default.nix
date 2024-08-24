{lib, self, inputs, pkgs}: let 
  callPackage = lib.callPackageWith (pkgs // packages // {inherit self inputs systemTest;});
  python3 = callPackage ./python3 {};
  systemTest = callPackage ./test.nix {};
  packages = {
    inherit (python3) diskinfo;
    generateUUID = callPackage ./generateUUID.nix {};
    deploy = callPackage ./deploy.nix {};
    installSystem = callPackage ./installSystem.nix {};
  };
in packages // systemTest
