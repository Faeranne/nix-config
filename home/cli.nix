{pkgs, ...}:
{
  home.packages = with pkgs; [
    silicon
    pinentry
    pinentry-curses
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
    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [
        exts.pass-otp
      ]);
    };
  };
  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "curses";
    };
  };
}
