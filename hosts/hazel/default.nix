{self, config, myLib, ...}: {
  imports = with self.nixosModules; [
    base 
    server
    extras.storage
    hardware.cpu.intel
    ./docker.nix
    ./networking.nix
    self.userModules.nina
  ];

  networking = {
    hostName = "hazel";
    hostId = "279e089e";
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/E6D1-9B8A";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "age1ma4a9xsfpl79agyltqaaey7cc7k8te5tcr4yqn494f4tn0272gqs7nvjkw";

  services = {
    zfs.autoScrub.pools = [ "zpool" ];
  };
}
