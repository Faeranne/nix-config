{...}:{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./git.nix
    ./vim.nix
    ./zsh.nix
    ./waybar.nix
    # System specific configs
    ./sarah.nix
  ];
  home = {
    sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "kitty";
    };
  };
}
