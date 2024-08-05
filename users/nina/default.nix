{config, pkgs, ...}: {

  nix.settings.trusted-users = [ "nina" ];

  home-manager.users.nina = {...}:{
    imports = [
      ./base.nix
    ];
  };
  users = {
    users.nina = {
      isNormalUser = true;
      group = "nina";
      uid = 1000;
      description = "Nexus";
      hashedPasswordFile = config.age.secrets."user-nina".path;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMg89gg80Z24JNaj1qeuEk4zxfA2AabKcuo6JHjSHu3xAAAAC3NzaDpwcml2YXRl nina@desktop"
      ];
      extraGroups = [
        "wheel"
        "docker"
        "tss"
        "adbusers"
        "dialout"
        "audio"
        "dialout"
      ];
    };
    groups.nina = {
      gid = 1000;
    };
  };

  age.secrets."user-nina".rekeyFile = ./password.age;
}
