{userConfig, ...}: {
  imports = [
    ./packages.nix
    ./ssh-agent.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
    ./git.nix
    ./styling.nix
  ];
  home = {
    stateVersion = "23.11";
  };
  programs.home-manager.enable = true;
  nix.settings = {
  };
}
