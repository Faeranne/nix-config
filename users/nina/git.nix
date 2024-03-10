{pkgs, ...}:
{
  programs = {
    git = {
      userEmail = "nina@projectmakeit.com";
      userName = "Faer-Anne";
    };
  };
  home.packages = with pkgs; [
    gource
  ];
}
