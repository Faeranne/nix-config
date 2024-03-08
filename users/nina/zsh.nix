{...}:
{
  programs = {
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "zsh-interactive-cd"
          "web-search"
          "wd"
          "vi-mode"
          "git"
          "python"
          "sudo"
          "systemd"
        ];
      };
    };
  };
}
