{pkgs, ...}:
{
  home.packages = with pkgs; [
    silicon
  ];
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    autojump = {
      enable = true;
      enableZshIntegration = true;
    };
    broot = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
