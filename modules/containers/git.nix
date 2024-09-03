{self, config, lib, pkgs, ...}:let
  containerName = "git";
  containerIp = lib.removeSuffix "/32" (builtins.elemAt config.networking.wireguard.interfaces."wg${containerName}".ips 0);
  sshWKey = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.gitSshKey.path}";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.10/32"]; #Prefer 10.100.1.x ips for containers
      peers = [
      ];
    };
  };

  users = {
    users.git = {
      group = "git";
      uid = 2000;
      isSystemUser = true;
    };
    groups.git = {
      gid = 2000;
    };
  };

  services.openssh.extraConfig = let
    shell = pkgs.writers.writeBash "ssh_shell" {} ''
      shift
      ${sshWKey} -o StrictHostKeyChecking=no git@${containerIp} "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $@"
    '';
    forgejoShim = pkgs.writers.writeBash "forgejo_shim" {} ''
      ${sshWKey} -o StrictHostKeyChecking=no git@${containerIp} "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
    '';
  in ''
    Match User git
      AuthorizedKeysCommandUser git
      AuthorizedKeysCommand ${sshWKey} -o StrictHostKeyChecking=no git@${containerIp} ${forgejoShim} keys -e git -u %u -t %t -k %k
      ForceCommand ${shell}
  '';

  age.secrets.gitSshKey = {
    rekeyFile = self + "/secrets/${config.networking.hostName}/gitSshKey.age";
    owner = "git";
    group = "git";
    mode = "770";
    generator = {
      script = "sshkey";
    };
  };


  containers.${containerName} = {
    bindMounts = {
      "/var/lib/forgejo" = { #Prefer not including host path here, save it for the host itself
        isReadOnly = false;
        create = true;
        owner = "container:container";
      };
      "/run/secrets/gitSshKey" = {
        hostPath = (lib.escapeShellArg (lib.removeSuffix ".age" (config.age.secrets.gitSshKey.rekeyFile) + ".pub"));
        isReadOnly = true;
      };
    };

    specialArgs = {
      port = 80;
    };

    config = let
      hostConfig = config;
    in {hostName, port, ...}: {
      imports = [
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ port ];
        };
      };
      services.forgejo = {
        enable = true;
        settings = {
          session = {
            COOKIE_SECURE=true;
          };
          server = {
            DOMAIN="${hostName}";
            HTTP_PORT=port;
            ROOT_URL="https://${hostName}";
          };
        };
      };
      users = {
        users = {
          forgejo = {
            uid = hostConfig.users.users.container.uid;
            openssh.authorizedKeys.keys = [
            ];
          };
          git = {
            group = "git";
            uid = hostConfig.users.users.git.uid;
            isNormalUser = true;
            createHome = true;
            openssh.authorizedKeys.keyFiles  = [
              # add the generated sshkey for git to the keyfile list.  hopefully this works as intended
              "/run/secrets/gitSshKey"
            ];
          };
        };
        groups = {
          forgejo.gid = hostConfig.users.groups.container.gid;
          git.gid = hostConfig.users.groups.git.gid;
        };
      };
    };
  };
}
