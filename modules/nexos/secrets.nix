{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge concatStringsSep mkOption flatten;
  inherit (lib.types) str package path;
  inherit (pkgs) writeShellScriptBin;
  enable = config.nexos.enable;
  global = config.nexos.global;
  secrets = config.nexos.security.secretsFolder;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
  testing = config.nexos.testing;

  secretLines = lib.foldlAttrs (acc: name: value: let
    line = ''
      echo Decrypting ${value.id} to ''${SECRETOUT}/${value.id}
      ${config.age.ageBin} -d -i "${global.age.primaryIdentityPath}" ${value.rekeyFile} | tee $SECRETOUT/${value.id} > /dev/null
    '';
  in acc++[line]) [] config.age.secrets;

  vm-rekey = assert (testing.dir != null); (concatStringsSep "\n" (flatten [
    ''
      SECRETOUT=${testing.dir}/secrets
      mkdir -p ${testing.dir}/persist
      chmod 700 $SECRETOUT
      rm -rf $SECRETOUT
      mkdir -p --mode=700 $SECRETOUT
      umask 277 #limit to 
      echo Installing secrets to $SECRETOUT
    ''
    secretLines
    ''
      chmod 500 $SECRETOUT
    ''
  ]));
in {
  imports = [
    inputs.ragenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];
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
      testing = {
        build = {
          vm-secrets = mkOption {
            type = package;
            description = ''
              Script that decrypts secrets from a primary key into testing folders for VM use.
            '';
            default = writeShellScriptBin "vm-secret" vm-rekey;
          };
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
      in mkMerge [
        {
          storageMode = "local";
          localStorageDir = secrets + "/rekeyed/${hostname}";
          generatedSecretsDir = secrets + "/generated/${hostname}";

          hostPubkey = mkIf (configFile != null) configFile.pubkey;
        }
        (mkIf global.enable {
          agePlugins = mkIf global.age.enableYubikey (with pkgs; [
            age-plugin-yubikey
          ]);

          masterIdentities = [
            global.age.primaryIdentityPath
          ];

          extraEncryptionPubkeys = global.age.primaryKeys;
        })
      ];
    };

    # Features only enabled if running as a vm using config.system.build.vm
    # also requires testing framework to be enabled.
    virtualisation.vmVariant = mkIf testing.enable {

      # Disables agenix and replaces it with host-provided secrets from vm-build
      system.activationScripts = {
        agenixNewGeneration.text = lib.mkVMOverride "";
        agenixInstall.text = lib.mkVMOverride ''
          ln -sfT /agenix /run/agenix
        '';
        agenixChown.text = lib.mkVMOverride "";
      };

      # Controls mounting the testing mount points, including agenix secrets and the /persist folder
      virtualisation = {
        sharedDirectories = {
          "agenix" = {
            target = "/agenix";
            source = testing.dir+"/secrets";
            securityModel = "passthrough";
          };
        };
      };
    };
  };
}
