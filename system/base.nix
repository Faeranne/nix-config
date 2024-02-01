{ self, config, lib, pkgs, inputs, primaryEthernet, ... }:
let
  sops = inputs.sops;
in
{
  system.configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";

  time.timeZone = "America/Indiana";
  i18n.defaultLocale = "en_US.UTF-8";

  sops.age.keyFile = "/persist/sops.key";

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
      allowedTCPPorts = [ ];
      extraCommands = ''
        iptables -t nat -A POSTROUTING -o ${primaryEthernet} -j MASQUERADE
      '';
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

  system.stateVersion = "23.11"; # Did you read the comment?
}
