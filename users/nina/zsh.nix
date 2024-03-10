{...}:
{
  programs = {
    zsh = {
      oh-my-zsh = {
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
