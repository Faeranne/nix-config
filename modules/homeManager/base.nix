{inputs, pkgs, ...}: {
  _module.args = {
    nur-no-packages = import inputs.nur {
      nurpkgs = pkgs;
    };
  };
  imports = [
    ./packages.nix
    ./ssh-agent.nix
    ./tmux.nix
    ./vim.nix
    ./zsh.nix
    ./git.nix
    ./styling.nix
    ./syncthing.nix
    inputs.nur.nixosModules.nur
  ];
  home = {
    persistence."/persist/home/nina" = {
      allowOther = false;
    };
    stateVersion = "23.11";
  };
  programs.home-manager.enable = true;
  nix.settings = {
  };
}
