{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3
    wget
    gitFull
    gita
    pkgs.chezmoi
    atuin
    mlocate
    htop
    dig
  ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    zsh = {
      enable = true;
    };
  };
}
