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
      masterIdentities = [ "yubikey.pub" ];
      extraEncryptionPubkeys = [ 
        "age1yubikey1qtfy343ld8e5sxlvfufa4hh22pm33f6sjq2usx6mmydrmu7txzu7g5xm9vr"
        "age1yubikey1qdnfvhjlw8j2dkksj9eyxaqwldtqw4427cqjjqxulr5t7gn4flnt25lhuyw"
        "age1yubikey1qw43gcah5lr95c4klyavduax0drqd5a95lhs8u2wpzqrtcklw5f0uwruyek"
        "age1yubikey1qwcdxfaalqhntrsrkt7p2nyngdyjc72jr8tehgdzgwwpsl0veflrxncut3x"
      ];
      hostPubkey = systemConfig.security.pubkey;
    };
  };
}
