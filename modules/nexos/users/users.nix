{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge mapAttrs concatMapAttrs;

  cfg = config.nexos.users;
  enable = config.nexos.enable;
  global = config.nexos.global;
  users = config.nexos.users.users;
  forEachUser = func: mapAttrs func users;
in mkIf enable {
  nexos.users.users = mkIf global.enable {

  };
  nix.settings.trusted-users = cfg.root;

  home-manager.users = forEachUser (name: userConf: userConf.hmModules);
  users = {
    users = forEachUser (name: userConf: mkMerge [
      {
        isNormalUser = true;
        group = name;
        uid = userConf.id;
        description = userConf.description;
        hashedPasswordFile = config.age.secrets."user-${name}".path;
        shell = userConf.shell pkgs;
        createHome = true;
        openssh.authorizedKeys.keys = userConf.keys;
        extraGroups = userConf.groups;
      }
      userConf.module
    ]);
    groups = forEachUser (name: userConf: {
      gid = userConf.id;
    });
  };

  age.secrets = concatMapAttrs (name: userConf: {
    "user-${name}".rekeyFile = userConf.passwordFile;
  }) users;
}
