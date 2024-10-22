{lib, self, inputs, pkgs}: let 
  callPackage = lib.callPackageWith (pkgs // packages // {inherit self inputs systemTest systemDeploy;});
  python3 = callPackage ./python3 {};
  systemTest = callPackage ./test.nix {};
  systemDeploy = callPackage ./deploy.nix {};
  packages = {
    inherit (python3) diskinfo;
    generateUUID = callPackage ./generateUUID.nix {};
    installSystem = callPackage ./installSystem.nix {};
    gatherClues = callPackage ./gatherClues.nix {};
    finishInstall = callPackage ./finishInstall.nix {};
    iso = callPackage ./iso.nix {};
    efi = callPackage ./efi.nix {};
    wifi = callPackage ./wifi.nix {};
  };
in packages // systemTest // systemDeploy
