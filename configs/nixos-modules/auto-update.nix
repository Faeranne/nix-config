{
  system = {
    autoUpgrade = {
      operation = "switch";
      flake = "git+https://git.faeranne.com/faeranne/nix-config?ref=rebuild-parts";
    };
  };
}
