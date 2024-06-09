{pkgs, ...}:
{
  programs = {
    git = {
      userEmail = "nina@projectmakeit.com";
      userName = "Faer-Anne";
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "ssh-ed25519 AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJ3irFjnNdb4EuLjzbl3i/kUz6Mcgo1qbI5f3yQ6qJFgAAAACnNzaDpnaXRodWI=";
      };
    };
  };
  home.packages = with pkgs; [
    gource
  ];
}
