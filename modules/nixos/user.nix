{config, systemConfig, lib, pkgs, ...}: {

  home-manager = {
    sharedModules = [ 
      ../homeManager 
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    users = lib.concatMapAttrs (name: attrs: {
      ${name} = {
        extraSpecialArgs = {
          inherit systemConfig;
          userConfig = attrs;
        };
      };
    } systemConfig.userConfigs)
  };

  nix.settings.trusted-users = systemConfig.root;
  security.sudo.wheelNeedsPassword = true;

  users.users = lib.concatMapAttrs (name: attrs: let
    isSudo = builtins.elem name systemConfig.root;
    isDesktop = (builtins.elem "gnome" systemConfig.elements) || (builtins.elem "kde" systemConfig.elements);
  in {
    ${name} = {
      isNormalUser = true;
      uid = attrs.uid;
      group = name;
      extraGroups = (
        [] ++ 
        ( if isSudo then [ "wheel" "docker" ] else [] ) ++ 
        ( if isDesktop then [ "audio" ] else [] )
      );
      description = attrs.name;
      hashedPasswordFile = config.age.secrets.user-${name}.path;
      openssh.authorizedKeys.keys = [] ++ attrs.authorizedKeys;
      shell = attrs.shell pkgs;
    };
  } systemConfig.userConfigs)
  users.groups = lib.concatMapAttrs (name: attrs: {
    ${name} = {
      gid = attrs.uid;
    };
  } systemConfig.userConfigs)
};
