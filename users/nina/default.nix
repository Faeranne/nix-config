{lib, ...}:
{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./git.nix
    ./vim.nix
    ./zsh.nix
    ./waybar.nix
  ];
  home = {
    sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "kitty";
    };
  };
}
