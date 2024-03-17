{pkgs, ...}:
{
  home.packages = with pkgs; [
    silicon
    pinentry
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
    kitty = {
      enable = true;
    };
    gpg.enable = true;
  };
  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "curses";
    };
  };
}
