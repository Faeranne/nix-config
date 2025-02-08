{
  self,
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.agenix-rekey.nixosModules.default
    inputs.ragenix.nixosModules.default
    ./age-pubkeys.nix
  ];
  age = {
    identityPaths = [
      "/nix/agenix.key"
    ];
    rekey = {
      storageMode = "local";
      localStorageDir = self + "/secrets/rekeyed/${config.networking.hostName}";
      agePlugins = [
        pkgs.age-plugin-yubikey
      ];
      generatedSecretsDir = self + "/secrets/generated";
      masterIdentities = ["/tmp/yubikey.pub"];
    };
  };
}
