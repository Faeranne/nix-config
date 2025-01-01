{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) str;
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
  config = {
    age = {
      identityPaths = [
        "/persist/agenix.key"
        "/nix/agenix.key"
      ];

      rekey = let
        hostname = config.nexos.info.name;
      in {

        storageMode = "local";
        localStorageDir = global.secretsDir + "/rekeyed/${hostname}";
        generatedSecretsDir = global.secretsDir + "/secrets/generated/${hostname}";

        agePlugins = mkIf global.enableYubikey (with pkgs; [
          age-plugin-yubikey
        ]);

        masterIdentities = [
          global.primaryIdentityPath
        ];

        extraEncryptionPubkeys = global.primaryKeys;

        hostPubkey = mkIf configFile configFile.pubkey;
      };
    };
  };
}
