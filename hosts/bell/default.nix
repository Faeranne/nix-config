{
  self,
  config,
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

  boot = {
    kernelModules = [ "thecus_it87" ];
    extraModulePackages = [
      (config.boot.kernelPackages.callPackage self+"/pkgs/thecus_it87.nix")
    ];
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
