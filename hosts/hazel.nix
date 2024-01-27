args@{ modulesPath, config, lib, pkgs, sops, disko, ... }: {
  imports =
    [
      ../system/disks.nix
      ../system/base.nix
      ../system/intel.nix
      ../services/podman.nix
      ../services/ssh.nix
      ../services/dns.nix
      ../services/foundry.nix
    ];
  _module.args = {
    rootDisk = "/dev/disk/by-path/pci-0000:00:17.0-ata-1";
    primaryEthernet = "eno1";
  };
  networking.hostName = "hazel"; # Define your hostname.
  networking.hostId = "279e089e";

  system.stateVersion = "23.11"; # Did you read the comment?
}
