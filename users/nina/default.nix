{lib, ...}:
{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./git.nix
    ./vim.nix
    ./zsh.nix
    ./hypr.nix
    ./waybar.nix
  ];
  home = {
    sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "kitty";
    };
  };
}
