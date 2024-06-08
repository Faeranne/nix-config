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
    extra-substituters = [ "https://yazi.cachix.org" ];
    extra-trusted-public-keys = [ "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k=" ];
  };
}
