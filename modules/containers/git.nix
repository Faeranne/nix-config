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
      isNormalUser = true;
      shell = "/etc/ssh/.ssh_shell-wrapper";
    };
    groups.git = {
      gid = 2000;
    };
  };

  environment.etc = {
    "ssh/.ssh_shell-wrapper" = {
      mode = "0555";
      text = ''
        #!${pkgs.bash}/bin/bash
        shift
        ${sshWKey} -o StrictHostKeyChecking=no forgejo@${containerIp} "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $@"
      '';
    };
    "ssh/.ssh_authorized-wrapper" = {
      mode = "0555";
      text = ''
        #!${pkgs.bash}/bin/bash
        ${sshWKey} -o StrictHostKeyChecking=no forgejo@${containerIp} "${pkgs.forgejo}/bin/gitea --config /var/lib/forgejo/custom/conf/app.ini keys -e git $@"
      '';
    };
  };

  services.openssh.extraConfig = ''
    Match User git
      AuthorizedKeysCommandUser git
      AuthorizedKeysCommand /etc/ssh/.ssh_authorized-wrapper -u %u -t %t -k %k
  '';

  age.secrets.gitSshKey = {
    rekeyFile = self + "/secrets/${config.networking.hostName}/gitSshKey.age";
    owner = "git";
    group = "git";
    mode = "700";
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
      "/etc/ssh/keys/" = {
        isReadOnly = false;
        create = true;
        permissions = "755";
      };
    };

    specialArgs = {
      port = 8000;
    };

    config = let
      hostConfig = config;
    in {hostName, port, ...}: {
      imports = [
        ./base.nix
      ];

      networking = {
        firewall = { # Make sure to add any ports needed for wireguard
          allowedTCPPorts = [ port 22 2222 ];
        };
      };
      services = {
        openssh = {
          enable = true;
          startWhenNeeded = false;
          hostKeys = [
            {
              bits = 4096;
              path = "/etc/ssh/keys/ssh_host_rsa_key";
              type = "rsa";
            }
            {
              path = "/etc/ssh/keys/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ];
        };
        forgejo = {
          enable = true;
          settings = {
            repository = {
              ENABLE_PUSH_CREATE_USER = true;
              ENABLE_PUSH_CREATE_ORG = true;
            };
            server = {
              START_SSH_SERVER=false;
              SSH_LISTEN_PORT=2222;
              SSH_CREATE_AUTHORIZED_KEYS_FILE=false;
              SSH_USER = "git";
              DOMAIN="${hostName}";
              HTTP_PORT=port;
              ROOT_URL="https://${hostName}";
            };
            service = {
              DISABLE_REGISTRATION = true;
            };
            session = {
              COOKIE_SECURE=true;
            };
          };
        };
      };
      users = {
        users = {
          forgejo = {
            uid = hostConfig.users.users.container.uid;
            openssh.authorizedKeys.keyFiles  = [
              # add the generated sshkey for git to the keyfile list.  hopefully this works as intended
              (lib.removeSuffix ".age" (config.age.secrets.gitSshKey.rekeyFile) + ".pub")
            ];
          };
          git = {
            group = "git";
            uid = hostConfig.users.users.git.uid;
            isNormalUser = true;
            createHome = true;
            openssh.authorizedKeys.keyFiles  = [
              # add the generated sshkey for git to the keyfile list.  hopefully this works as intended
              (lib.removeSuffix ".age" (config.age.secrets.gitSshKey.rekeyFile) + ".pub")
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
