{
  self,
  config,
  pkgs,
  ...
}: let
  global = self.globalConfig;
in {
  age = {
    identityPaths = [
      "/persist/agenix.key"
      "/nix/agenix.key"
    ];

    rekey = let
      hostname = config.nexos.info.name;
    in {
      storageMode = "local";
      localStorageDir = self + "/secrets/rekeyed/${hostname}";
      generatedSecretsDir = self + "/secrets/generated/${hostname}";
      agePlugins = with pkgs; [
        age-plugin-yubikey
      ];
      masterIdentities = [
        "/tmp/yubikey.pub"
      ];

      extraEncryptionPubkeys = [];
    };
  };
}
