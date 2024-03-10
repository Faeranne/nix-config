{pkgs, lib, ...}:
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = lib.mkDefault true;
      viAlias = lib.mkDefault true;
      vimAlias = lib.mkDefault true;
      vimdiffAlias = lib.mkDefault true;
    };
  };
}
