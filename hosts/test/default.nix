{self, config, pkgs, ...}:let
  localCfg = builtins.fromJSON ./config.json;
in {
  imports = with self.nixosModules; [
    base 
    desktop
    services.clamav
    extras.storage
    hardware.cpu.intel
    self.userModules.nina
  ];

  networking = {
    hostName = "test";
    hostId = "520ca999";
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/${localCfg.bootId}";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  topology.self = {
    name = "Test";
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  age.rekey.hostPubkey = "${localCfg.pubkey}";
}
