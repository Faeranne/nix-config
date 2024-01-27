{ config, lib, pkgs, sops, primaryEthernet ? "eno0", ... }:
{
  imports = [
    ./users.nix
    ./impermanence.nix
  ];

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
  networking.useNetworkd = true;
  networking.nat.externalInterface = primaryEthernet;

  systemd.network = {
    networks = {
      "10-lan1" = {
        matchConfig.Name=primaryEthernet;
        networkConfig.DHCP = "ipv4";
      };
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8081 ];
    };
  };

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
