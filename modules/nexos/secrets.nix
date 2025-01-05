{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) str;
  enable = config.nexos.enable;
  global = self.globalConfig;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {
  options = {
    nexos = {
      security = {
        age = {
          pubkey = mkOption {
            type = str;
            description = ''
              sets the host's public key used in agenix.  This is commonly set in a `config.json`.
            '';
          };
        };
      };
    };
  };
  config = mkIf enable {
    age = {
      identityPaths = [
        "/persist/agenix.key"
        "/nix/agenix.key"
      ];

      rekey = let
        hostname = config.nexos.info.name;
      in {

        storageMode = "local";
        localStorageDir = global.age.secretsDir + "/rekeyed/${hostname}";
        generatedSecretsDir = global.age.secretsDir + "/secrets/generated/${hostname}";

        agePlugins = mkIf global.age.enableYubikey (with pkgs; [
          age-plugin-yubikey
        ]);

        masterIdentities = [
          global.age.primaryIdentityPath
        ];

        extraEncryptionPubkeys = global.primaryKeys;

        hostPubkey = mkIf (configFile != null) configFile.pubkey;
      };
    };
  };
}
