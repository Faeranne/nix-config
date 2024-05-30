{ config, systemConfig, lib, pkgs, ... }: let
  util = import ../../lib/utils;
  inherit (util) getUserConfig;
  isImpermanent = (builtins.elem "impermanence" systemConfig.elements);
  isServer = (builtins.elem "server" systemConfig.elements);
  # We get the rekey file locations for secrets that are pregenerated
  # aka: can't be generated automatically.  This is things like vpn credentials
  pregenEntries = lib.genAttrs (if (builtins.hasAttr "preset" systemConfig.security) then (systemConfig.security.preset) else []) (name: {
    rekeyFile = ../../hosts/${systemConfig.hostname}/secrets/${name}.age;
  });
  # and we setup generated secrets here.  These can be generated during setup
  # rather than needing some pre-defined value.  These can change at any time
  # and shouldn't be relied on being stable.  This can also generate secret
  # pairs. things like wireguard keypairs.
  generateEntries = lib.mapAttrs (name: value: {
    rekeyFile = ../../hosts/${systemConfig.hostname}/secrets/${name}.age;
    generator = value;
  }) (if (builtins.hasAttr "generate" systemConfig.security) then systemConfig.security.generate else {}) ;
  pubkeyList = pkgs.writeText "sudoKeys" ''
    ${builtins.concatStringsSep "\n" (builtins.concatMap (user: (getUserConfig user).authorizedKeys) systemConfig.sudo)}
  '';
in{
  # Enable TPM2 for laptops and other TPM protected computers.
  # These are only used as a basis for speed-boot options, and
  # should be covered by a secondary key option
  # Boot options first
  boot.initrd.systemd.enableTpm2 = true;
  # Runtime TPM options. these are for managing the TPM, and
  # are not used for any actual encryption/decryption
  security = {
    tpm2 = {
      enable = true;
      tctiEnvironment.enable = true;
      pkcs11.enable = true;
    };
    polkit = {
      enable = true;
    };
    pam = {
      services = {
        swaylock = {};
        sudo = lib.mkIf isServer {
          # TODO: This uses the experimental "rules" feature introduced with NixOS/nixpkgs#255547
          # Be sure to keep an eye on it for future changes
          rules = {
            auth = {
              rssh = {
                order = config.security.pam.services.su.rules.auth.unix.order - 10;
                control = "sufficient";
                modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
                settings = {
                  debug = true;
                  auth_key_file = pubkeyList;
                };
              };
            };
          };
        };
      };
      sshAgentAuth = {
        enable = true;
      };
    };
  };
  # PCSCD enables access to things like Yubikeys.
  services = {
    pcscd.enable = true;
    tcsd.enable = true;
  };
  environment = lib.mkIf isImpermanent {
    persistence."/persist" = {
      directories = [
        "/var/lib/tpm"
      ];
    };
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
    # We're handling pre-adding secrets based on the hostConfig to allow for
    # dynamic usage of secrets.  Here we use that list to actually put the secrets
    # into the age system.  We also handle setting up generated secrets here too.
    secrets = pregenEntries//generateEntries;
    # All these are agenix-rekey options.  This allows using derivations to store
    # the host-encrypted parts.  All secrets still need to be first decrypted with
    # a provided yubikey/hardware token, but then are re-encrypted with the host
    # specific key.
    rekey = {
      # This causes agenix-rekey to use a local fileset instead of derivations for
      # rekeyed files.  Since derivations have ended up being fradgle, and don't
      # work great when used on multiple build hosts (like trying to build for a
      # laptop on said laptop), I switched recently to the local format.
      # If derivations get less fradgile (unlikely), then switching back is really
      # easy.
      storageMode = "local";
      # This defines the folder that the rekeyed secrets are actually stored in.
      # It's inside this repo, and must be unique per host to actually behave
      # correctly.  We're doing `../.. +` to get path values to behave correctly.
      # Don't ask me why this works, I spent nearly an hour fiddling with it to
      # make it behave, and now that it works, I'm relying on Nix's declaritive
      # format to ensure I never have to poke it again.
      localStorageDir = ../.. + "/secrets/rekeyed/${systemConfig.hostname}";
      # Gotta include the age-plugin-yubikey package to support yubikey decryption.
      #NOTE: we're using the stable version for the moment till nixos/nixpkgs#309297
      # is merged.  libpcsclite is broken in the current unstable.
      agePlugins = [ pkgs.stable.age-plugin-yubikey ];
      # No secrets are generated at this time, but this is set for those cases.
      generatedSecretsDir = ../../secrets/generated;
      # ~~Due to how derivations are generated, we gotta do all rekey operations on
      # a specific system type. Since no primary system is arm based, I just force
      # agenix to use a x64 system for rekey.  This makes rekey operations work
      # when doing cross-system builds.~~
      # UPDATE: This is no longer the case since we now use local rekey operations
      # As such I'm just disabling it for now. If derivations become an option again
      # This will need to be re-enabled.
      #forceRekeyOnSystem = "x86_64-linux";
      # This is the public side of the currently installed Yubikey.  A seperate command [1]
      # fetches the public side and sticks it here, so this operation isn't entirely
      # idempotent, as it doesn't work without a valid harware key.  This is expected
      # and required for proper secret management... sadly.
      # [1] specifically `nix develop` in this repo, which calls `age-plugin-yubikey -L`
      # and puts the results here.
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
      # This is used by rekey to eventually generate the `secrets/rekeyed/` files for
      # this particular host.
      hostPubkey = systemConfig.security.pubkey;
    };
  };
}
