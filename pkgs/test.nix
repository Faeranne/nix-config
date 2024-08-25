{pkgs, self, inputs}: let
  inherit (inputs.nixpkgs.lib) foldlAttrs;
in foldlAttrs (acc: host: system:
  let
    secrets = system.config.age.secrets;
    secretList = foldlAttrs (acc: name: value: acc + ''
      echo "Decrypting secret ${name}"
      mkdir -p `dirname /tmp/vmManagement/secretManagement/${value.path}`
      ${pkgs.age}/bin/age --decrypt -i /tmp/yubikey.pub -o /tmp/vmManagement/secretManagement/${value.path} ${value.rekeyFile}
    '') ''
      mkdir -p /tmp/vmManagement/secretManagement/
      ${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey --identity > /tmp/yubikey.pub
    '' secrets;
  in acc // {
    "test-${host}" = pkgs.writers.writeBashBin "install_system" {} ''
      rm -rf /tmp/vmManagement/
      ${secretList}
      mkdir -p /tmp/vmManagement/persist/
    '';
  }
) {} self.nixosConfigurations

