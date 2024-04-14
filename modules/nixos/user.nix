{config, inputs, systemConfig, lib, pkgs, flakeUtils, ...}: {

  home-manager = {
    sharedModules = [ 
      ../homeManager 
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit systemConfig;
    };
    users = lib.genAttrs systemConfig.users (username: 
      {...}: let
        module = flakeUtils.getUserModule username;
      in { 
        _module.args = {
          userConfig = flakeUtils.getUserConfig username;
        };
        imports = [
          module
        ];
      }
    );
  };

  nix.settings.trusted-users = systemConfig.sudo;
  security.sudo.wheelNeedsPassword = true;

  users.users = lib.genAttrs systemConfig.users (name: let
    isSudo = builtins.elem name systemConfig.sudo;
    isGnome = (builtins.elem "gnome" systemConfig.elements);
    isKde = (builtins.elem "kde" systemConfig.elements);
    isGraphical = isGnome || isKde;
    isVirtualize = (builtins.elem "virtualization" systemConfig.elements);
    attrs = import ../../users/${name}/config.nix;
  in {
    isNormalUser = true;
    uid = attrs.uid;
    group = name;
    extraGroups = (
      ( if isSudo then [ "wheel" "docker" "tss" ] else [] ) ++ 
      ( if isGraphical then [ "audio" ] else [] ) ++
      ( if (isSudo && isVirtualize) then [ "vboxusers" ] else [] )
    );
    description = attrs.name;
    hashedPasswordFile = config.age.secrets."user-${name}".path;
    openssh.authorizedKeys.keys = [] ++ attrs.authorizedKeys;
    shell = attrs.shell pkgs;
  });
  users.groups = lib.genAttrs systemConfig.users (name: let
    attrs = import ../../users/${name}/config.nix;
  in {
    gid = attrs.uid;
  });
  age.secrets = builtins.foldl' (input: name: let
    attrs = import ../../users/${name}/config.nix;
  in
    input // {
      "user-${name}".rekeyFile = attrs.passwordPath;
    }
  ) {} systemConfig.users;
  systemd.services = builtins.foldl' (input: name: let
    attrs = import ../../users/${name}/config.nix;
  in
    input // {
      "set${name}icon" = lib.mkIf (attrs ? avatar) {
        serviceConfig = {
          Type = "oneshot";
        };
        enable = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "accounts-daemon.service" ];
        before = [ "display-manager.service" ];
        requires = [ "accounts-daemon.service" ];
        script = ''
          cp ${attrs.avatar} /var/lib/AccountsService/icons/${name};
          echo "[User]
          Session=
          Icon=/var/lib/AccountsService/icons/${name}
          SystemAccount=false" > /var/lib/AccountsService/users/${name};
        '';
      };
    }
  ) {} systemConfig.users;
}
