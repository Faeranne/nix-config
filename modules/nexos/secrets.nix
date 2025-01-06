{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) str path;
  enable = config.nexos.enable;
  global = config.nexos.global;
  secrets = config.nexos.security.secretsFolder;
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
        secretsFolder = mkOption {
          type = path;
          description = ''
            Location of all secrets.
          '';
        };
      };
    };
  };
  config = mkIf enable {
    nexos.security.secretsFolder = mkIf global.enable global.age.secretsDir;
    age = {
      identityPaths = [
        "/persist/agenix.key"
        "/nix/agenix.key"
      ];

      rekey = let
        hostname = config.nexos.info.name;
      in {

        storageMode = "local";
        localStorageDir = secrets + "/rekeyed/${hostname}";
        generatedSecretsDir = secrets + "/generated/${hostname}";

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
