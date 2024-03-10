{config, inputs, systemConfig, lib, pkgs, ...}: {

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
      {...}: { 
        _module.args = {
          userConfig = { inherit username; } // import ../../users/${username}/config.nix;
        };
        imports = [
          ../homeManager
          ../../users/${username}
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
    attrs = import ../../users/${name}/config.nix;
  in {
    isNormalUser = true;
    uid = attrs.uid;
    group = name;
    extraGroups = (
      [] ++ 
      ( if isSudo then [ "wheel" "docker" ] else [] ) ++ 
      ( if isGraphical then [ "audio" ] else [] )
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
      "user-${name}".rekeyFile = ../../secrets/users/${name}.age;
    }
  ) {} systemConfig.users;
  system.activationScripts = builtins.foldl' (input: name: let
    attrs = import ../../users/${name}/config.nix;
  in
    input // {
      "set${name}icon".text = lib.mkIf (attrs ? avatar) ("cp ${attrs.avatar} /var/lib/AccountsService/icons/${name}");
    }
  ) {} systemConfig.users;
}
