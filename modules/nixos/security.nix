{ systemConfig, lib, pkgs, ... }: let
  localSystem = builtins.elem "local" systemConfig.elements;
in{
  # Enable TPM2 for laptops and other TPM protected computers.
  # These are only used as a basis for speed-boot options, and
  # should be covered by a secondary key option
  # Boot options first
  boot.initrd.systemd.enableTpm2 = true;
  # Runtime TPM options. these are for managing the TPM, and
  # are not used for any actual encryption/decryption
  security.tpm2 = {
    enable = true;
    tctiEnvironment.enable = true;
    pkcs11.enable = true;
  };
  # PCSCD enables access to things like Yubikeys.
  services = {
    pcscd.enable = true;
  };
  # agenix requirements. Agenix handles Activation Time decryption of secrets
  # which makes for a more robust rebuild operation.  More stuff can be setup
  # during the nix build process.  It does so by encrypting secrets with a host
  # specific key, and decrypting the secret into a `/run/secrets` folder when
  # the activation scripts run (so both after a rebuild and during boot).
  # Rekey handles storing these secrets cleanly in the git repo without needing
  # to manually rekey secrets every time a system is added/updated.
  age = {
    # In persistant systems, we store the key at `/persist/agenix.key`, but in
    # non-persistant systems it's at `/nix/agenix.key`.  These are otherwise
    # the same key. We specifically use a custom key as not all systems using
    # agenix encrypted secrets have a functioning OpenSSH daemon running, so
    # host keys aren't always available.
    identityPaths = [ "/persist/agenix.key" "/nix/agenix.key" ];
    # All these are agenix-rekey options.  This allows using derivations to store
    # the host-encrypted parts.  All secrets still need to be first decrypted with
    # a provided yubikey/hardware token, but then are re-encrypted with the host
    # specific key.
    rekey = {
      storageMode = "derivation";
      # Gotta include the age-plugin-yubikey package to support yubikey decryption.
      agePlugins = [ pkgs.age-plugin-yubikey ];
      # No secrets are generated at this time, but this is set for those cases.
      generatedSecretsDir = ../../secrets;
      # Due to how derivations are generated, we gotta do all rekey operations on
      # a specific system type. Since no primary system is arm based, I just force
      # agenix to use a x64 system for rekey.  This makes rekey operations work
      # when doing cross-system builds.
      forceRekeyOnSystem = "x86_64-linux";
      # This is the public side of the currently installed Yubikey.  A seperate command
      # fetches the public side and sticks it here, so this operation isn't entirely
      # idempotent, as it doesn't work without a valid harware key.  This is expected
      # and required for proper secret management... sadly.
      masterIdentities = [ "/tmp/yubikey.pub" ];
      # Every potential hardware key is listed here.  It's seperate from the above
      # option as for whatever reason, age doesn't cleanly handle multiple plugin-yubikey
      # identities in one location.  *shrug*
      # Each system that is intended to handle deploys has one of these, as well as a
      # backup key incase everything goes to hell.
      extraEncryptionPubkeys = [ 
        "age1yubikey1qtfy343ld8e5sxlvfufa4hh22pm33f6sjq2usx6mmydrmu7txzu7g5xm9vr"
        "age1yubikey1qdnfvhjlw8j2dkksj9eyxaqwldtqw4427cqjjqxulr5t7gn4flnt25lhuyw"
        "age1yubikey1qw43gcah5lr95c4klyavduax0drqd5a95lhs8u2wpzqrtcklw5f0uwruyek"
        "age1yubikey1qwcdxfaalqhntrsrkt7p2nyngdyjc72jr8tehgdzgwwpsl0veflrxncut3x"
      ];
      # This is the public side of the key stored in the identityPath.
      # The actual key data is stored in the `hosts/<name>/config.nix` file.
      hostPubkey = systemConfig.security.pubkey;
    };
  };
}
