{...}:
{
  programs = {
    tmux = {
      enable = true;
      keyMode = "vi";
      newSession = true;
      tmuxinator.enable = true;
    };
  };
  home.shellAliases = {
    mux = "tmuxinator";
  };
}
