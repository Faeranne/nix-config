{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) listOf str submodule;

  enable = config.nexos.enable;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  options = {
    nexos = {
      users = mkOption {
        default = {};
        type = submodule {
          options = {
            root = mkOption {
              type = listOf str;
              default = [];
            };
            users = config.nexos.lib.options.users;
          };
        };
      };
    };
  };
  config = mkIf enable {
    security.sudo.wheelNeedsPassword = true;
    users = {
      mutableUsers = false;
    };

    age = {
      generators = {
        sshkey = {
          pkgs,
          file,
          ...
        }: ''
          priv=$(mkfifo key && ((cat key ; rm key)&) && (echo y | ${pkgs.openssh}/bin/ssh-keygen -N "" -q -f key > /dev/null))
          cat key.pub > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
          echo "$priv"
        '';
      };
    };

    environment.createDir = [
      {
        path = "/persist/home";
        owner = "nobody:users";
        permissions = "775";
      }
    ];

    home-manager = {
      backupFileExtension = "bak";
      sharedModules = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        ./home-manager-default.nix
      ];
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
        systemConfig = config;
      };
    };
  };
}
