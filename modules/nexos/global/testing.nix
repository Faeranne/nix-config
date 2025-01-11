{
  lib,
  ...
}: let
  inherit (lib) mkOption;
  inherit (lib.types) str submodule;

in {
  options = {
    testing = mkOption {
      description = ''
        Options handling tesitng in VMs
      '';
      default = {};
      type = submodule {
        options = {
          dir = mkOption {
            description = ''
              Where to store testing files, including decrypted secrets for agenix
            '';
            type = str;
            default = "/tmp/vmTesting";
          };
        };
      };
    };
  };
}

