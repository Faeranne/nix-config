{ modulesPath, config, lib, pkgs, sops, ... }: {
  imports =
    [
      ../system/disks.nix
      ../system/base.nix
      ../system/intel.nix
      ../services/ssh.nix
    ];
  _module.args = {
    primaryEthernet = "enp0s6";
  };
  networking.hostName = "oracle1"; # Define your hostname.
  networking.hostId = "badc65d2";

  system.stateVersion = "23.11"; # Did you read the comment?
}
