{
  pkgs,
  self,
  inputs,
}: let
  inherit (inputs.nixpkgs.lib) getExe foldlAttrs;
in
  foldlAttrs (
    acc: host: system: let
    in
      acc
      // {
        "test-${host}" = pkgs.writers.writeBashBin "test_system" {} ''
          ${getExe pkgs.age-plugin-yubikey} --identity > ${self.globalConfig.age.primaryIdentityPath}
          ${getExe system.config.nexos.testing.build.vm-secrets}
          ${getExe system.config.system.build.vm}
        '';
      }
  ) {}
  self.nixosConfigurations
