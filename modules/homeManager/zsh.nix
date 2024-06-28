{...}:
{
  programs = {
    starship = {
      enable = true;
      settings = {
        sudo = {
          disabled = false;
        };
      };
    };
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = false;
      };
      prezto = {
        enable = true;
        editor = {
          keymap = "vi";
          dotExpansion = true;
          promptContext = true;
        };
        tmux = {
          autoStartLocal = true;
        };
        pmodules = [
          "tmux"
          "git"
        ];
      };
    };
  };
}
