{config, pkgs, ...}: {

  nix.settings.trusted-users = [ "livingroom" ];

  home-manager.users.livingroom = {...}:{
    imports = [
      ./base.nix
    ];
  };
  users = {
    users.livingroom = {
      isNormalUser = true;
      group = "livingroom";
      uid = 1001;
      description = "Living Room Computer";
      hashedPasswordFile = config.age.secrets."user-livingroom".path;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
      ];
      extraGroups = [
        "audio"
      ];
    };
    groups.livingroom = {
      gid = 1001;
    };
  };

  age.secrets."user-livingroom".rekeyFile = ./password.age;
}
