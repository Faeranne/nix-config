{lib, ...}:
{
  imports = [
    ./cli.nix
    ./git.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
  ];
  programs.home-manager.enable = true;
  home = {
    stateVersion = "23.11";
    username = "nix-on-droid";
    homeDirectory = "/data/data/com.termux.nix/files/home";
    sessionVariables = {
    };
  };
}
