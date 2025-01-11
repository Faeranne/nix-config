{
  writeShellScriptBin,
  lib,
  inputs,
  callPackage,
  rage,
  self,
  ...
}: let
  ageLib = callPackage (inputs.agenix-rekey + "/nix/lib.nix") {
    agePackage = rage;
    nodes = self.nixosConfigurations;
    userFlake = self;
  };
  hosts = lib.foldlAttrs (acc: name: value: let
    secretLines = lib.foldlAttrs (acc2: name2: value2: let
      line = ''
        echo ${ageLib.ageMasterDecrypt}
      '';
    in ""+line) "" value.config.age.secrets;
  in {
    "vm-rekey-${name}" = writeShellScriptBin "vm-rekey-${name}" ''
      ${secretLines}
    '';
  }) {} self.nixosConfigurations;
in 
  hosts
