{pkgs, ...}:
{
  programs = {
    tmux = {
      enable = true;
      keyMode = "vi";
      newSession = true;
      prefix = "C-Space";
      tmuxinator.enable = true;
      plugins = with pkgs; [
        tmuxPlugins.sensible
        tmuxPlugins.vim-tmux-navigator
      ];
      mouse = true;
      baseIndex = 1; 
      extraConfig = ''
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
        bind '"' split-window -v -c "#{pane_current_path}"
        bind '%' split-window -h -c "#{pane_current_path}"
      '';
    };
  };
  home.shellAliases = {
    mux = "${pkgs.tmuxinator}/bin/tmuxinator";
  };
}
