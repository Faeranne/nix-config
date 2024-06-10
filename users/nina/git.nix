{pkgs, ...}:
{
  programs = {
    git = {
      userEmail = "nina@projectmakeit.com";
      userName = "Faer-Anne";
      # oop, I need to make this merge with `modules/homeManager/git.nix`'s extraConfig
      #extraConfig = {
        # I guess this isn't quite ready to be used here.
        #commit.gpgsign = true;
        #gpg.format = "ssh";
        # Something about needing to use an on-disk file? I need to research this a bit better.
        #user.signingkey = "ssh-ed25519 ";
      #};
    };
  };
  home.packages = with pkgs; [
    gource
  ];
}
