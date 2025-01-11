{
  config,
  self,
  lib,
  ...
}: let
  inherit (builtins) length;
  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types) listOf str path submodule;

  cfg = config.age;
in {
  options = {
    age = mkOption {
      description = "Agenix configs for all systems.";
      type = submodule {
        options = {
          enableYubikey = mkEnableOption ''
            If the yubikey plugin should be used for primary keys.

            Note that leaving this false will prevent effective use of cross-system private identity files,
            as the identity file *must* exist for agenix-rekey to work correctly, and you cannot have multiple
            identity files unless all exist at the same time.
          '';
          secretsDir = mkOption {
            description = "Path to store all secrets in.";
            default = self + "/secrets";
            type = path;
          };
          primaryIdentityPath = mkOption {
            description = ''
              Where the primary identity file is stored and referenced, for the use with primary keys. If yubikey support is enabled,
              this is where the temporary private identity file is stored.  Otherwise, this should point to the system's private identity.
              This *must* be a string, not a path.
            '';
            default = "/tmp/yubikey.pub";
            type = str;
          };
          primaryKeys = mkOption {
            description = ''
              List of Public Keys to encrypt all secrets with at rest.
              Note that this option requires the Yubikey setting to be set.
            '';
            type = listOf str;
          };
        };
      };
    };
  };
  config = {
    assertions = [
      {
        assertion = ((length cfg.primaryKeys) > 0) -> cfg.enableYubikey;
        message = "Primary Keys can't be set without using Yubikey";
      }
    ];
  };
}
