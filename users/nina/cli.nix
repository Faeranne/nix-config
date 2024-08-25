{pkgs, ...}:
{
  home = {
    packages = with pkgs; [
      silicon
      pinentry
      passage
      picocom
    ];
    persistence."/persist/home/nina" = {
      directories = [
        ".mozilla"
        "projects"
        "src"
        "workspace"
        "nix-config"
      ];
      files = [
      ];
    };
  };
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
    thefuck = {
      enable = true;
      enableZshIntegration = true;
    };
  };
  services = {
    gpg-agent = {
      enable = false;
    };
  };
}
