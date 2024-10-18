{self, config, pkgs, ...}: {

  nix.settings.trusted-users = [ "nina" ];

  home-manager.users.nina = {...}:{
    imports = [
      (self + "/users/nina/vim.nix")
      (self + "/users/nina/zsh.nix")
      ({...}:{
        home = {
          packages = with pkgs; [
            pinentry
          ];
          persistence."/persist/home/nina" = {
            directories = [
            ];
          };
        };
        programs = {
          gpg.enable = true;
          git = {
            userEmail = "nina@projectmakeit.com";
            userName = "Faer-Anne";
          };
        };
        services = {
          gpg-agent = {
            enable = false;
          };
        };
      })
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
      extraGroups = [
        "wheel"
      ];
    };
    groups.nina = {
      gid = 1000;
    };
  };

  age.secrets."user-nina".rekeyFile = self + "/users/nina/password.age";
}
