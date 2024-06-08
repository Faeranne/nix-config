{pkgs, ...}:
{
  programs = {
    tmux = {
      enable = true;
      keyMode = "vi";
      newSession = true;
      tmuxinator.enable = true;
      extraConfig = ''
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
      '';
    };
  };
  home.shellAliases = {
    mux = "${pkgs.tmuxinator}";
  };
}
