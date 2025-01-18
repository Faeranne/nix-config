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
      allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
      allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export   192.168.1.*(rw,fsid=0,no_subtree_check)
      /export/nixstore   192.168.1.*(ro,nohide=0,insecure,no_subtree_check)
    '';
  };

  boot = {
    kernelModules = [ "thecus_it87" ];
    extraModulePackages = [
      (config.boot.kernelPackages.callPackage (self+"/pkgs/thecus_it87.nix") {})
    ];
  };

  environment.systemPackages = [
  ];

  age.rekey.hostPubkey = "${localCfg.pubkey}";

  fileSystems = {
    "/export" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "mode=755" ];
    };
    "/export/nixstore" = {
      device = "/nix/store";
      options = [ "bind" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/${localCfg.bootID}";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
