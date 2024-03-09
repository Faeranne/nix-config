{ systemConfig, lib, pkgs, ... }: let
  localSystem = builtins.elem "local" systemConfig.elements;
in{
  services = {
    udev.packages = with pkgs; lib.mkIf localSystem [ yubikey-personalization ];
    pcscd.enable = true;
  };
  age = {
    identityPaths = [ "/persist/agenix.key" "/nix/agenix.key" ];
    rekey = {
      storageMode = "derivation";
      agePlugins = [ pkgs.age-plugin-yubikey ];
      generatedSecretsDir = ../../secrets;
      forceRekeyOnSystem = "x86_64-linux";
      masterIdentities = [ ../../secrets/identities/yubikey.pub ];
      hostPubkey = systemConfig.security.pubkey;
    };
  };
}
