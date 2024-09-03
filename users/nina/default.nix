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
      createHome = true;
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMg89gg80Z24JNaj1qeuEk4zxfA2AabKcuo6JHjSHu3xAAAAC3NzaDpwcml2YXRl nina@desktop"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIG5g/WtYRcIvzMDK2WA/s0slpRANkq7PonQvO1cJFPEdAAAACnNzaDpnaXRodWI="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMfP0SmLYvOADVdv/13xY9Zl+y9GvU4raj2tR8rafrH8 nina@laura"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHaZdzhsaWij6kCBDoyJenqQ1pqrmIoWhOnBm5VYvV0iAAAACnNzaDpnaXRodWI= nina@sarah"
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
