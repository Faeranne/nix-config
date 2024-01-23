{self, config, lib, pkgs, sops, ... }:
{
  imports = [
    ./users.nix
    ./impermanence.nix
  ];

  system.configurationRevision = lib.mkIf (self ? rev) self.rev;

  boot.zfs.forceImportRoot = false;

  time.timeZone = "America/Indiana";
  i18n.defaultLocale = "en_US.UTF-8";

  sops.age.keyFile = "/persist/sops.key";

  environment.systemPackages = with pkgs; [
    wget
    gitFull
    gita
    pkgs.chezmoi
    atuin
    mlocate
  ];

  systemd.network.enable = true;

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
