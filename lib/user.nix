{ inputs }: username: cfg: let
  isSudo = (builtins.elem username cfg.base.root);
  isDesktop = (builtins.elem "desktop" cfg.base.elements);
  homeModules = (import ../homemodules.nix {inherit inputs username cfg;});
in {
  system: {config, ...}: {
    users.users.${username} = {
      isNormalUser = true;
      uid = cfg.user.uid;
      group = username;
      extraGroups = (
        [] ++ 
        ( if isSudo then [ "wheel" "docker" ] else [] ) ++ 
        ( if isDesktop then [ "audio" ] else [] )
      );
      description = cfg.user.name;
      hashedPasswordFile = config.age.secrets.user-${username}.path;
      openssh.authorizedKeys.keys = [] ++ cfg.user.authorizedKeys;
      shell = cfg.user.shell;
    };
    users.groups.${username} = {
      gid = cfg.user.uid;
    };
  };
  homemanager: {...}: {
    imports = [] ++ homeModules;
    programs.home-manager.enable = true;
    home = {
      stateVersion = "23.11";
      username = username;
      homeDirectory = "/home/${username}";
    };
  };
  droid: {
  };
}
