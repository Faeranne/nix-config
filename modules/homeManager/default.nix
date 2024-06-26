{userConfig, ...}: {
  imports = [
    ./desktop.nix
    ./git.nix
    ./packages.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
    ./ssh.nix
    ./styling.nix
  ];
  home = {
    stateVersion = "23.11";
    username = userConfig.username;
    homeDirectory = "/home/" + userConfig.username;
  };
  programs.home-manager.enable = true;
  nix.settings = {
  };
}
