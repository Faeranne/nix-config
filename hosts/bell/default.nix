{
  self,
  ...
}: let
  localCfg = builtins.fromJSON (builtins.readFile ./config.json);
in {
  imports = with self.nixosModules; [
    base
    server
    extras.storage
    hardware.cpu.intel
    self.userModules.nina
  ];

  networking = {
    hostName = "bell";
    hostId = "1cd0fa6c";
    firewall = {
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  environment.systemPackages = [
  ];

  age.rekey.hostPubkey = "${localCfg.pubkey}";

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/${localCfg.bootID}";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
