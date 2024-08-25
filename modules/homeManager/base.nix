{inputs, pkgs, ...}: {
  _modules.args = {
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
    inputs.nix-topology.nixosModules.default
  ];
  home = {
    /*
    persistence."/persist/home/nina" = {
      directories = [
      ];
      files = [
        ".ssh/known_hosts"
      ];
      allowOther = false;
    };
    */
    stateVersion = "23.11";
  };
  programs.home-manager.enable = true;
  nix.settings = {
  };
}
