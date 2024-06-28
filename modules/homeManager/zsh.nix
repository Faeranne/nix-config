{...}:
{
  programs = {
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
        };
        prompt = {
          theme = "adam";
        };
        tmux = {
          autoStartLocal = true;
        };
        pmodules = [
          "tmux"
        ];
      };
    };
  };
}
