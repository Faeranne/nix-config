{lib, ...}:
{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./git.nix
    ./packages.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
  ];
  home = {
    sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "kitty";
    };
  };
}
