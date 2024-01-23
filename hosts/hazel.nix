{ modulesPath, config, lib, pkgs, sops, ... }: {
  imports =
    [
      ./hazel-disks.nix
      ../system/base.nix
      ../system/intel.nix
      ../services/ssh.nix
    ];

  networking.hostName = "hazel"; # Define your hostname.
  networking.hostId = "279e089e";
  networking.useNetworkd = true;
  networking.nat.externalInterface = "eno1";

  systemd.network = {
    enable = true;
    networks = {
      "10-lan1" = {
        matchConfig.Name="eno1";
        networkConfig.DHCP = "ipv4";
      };
    };
  };

  networking = {
    firewall = {
      enable = true;
    };
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
