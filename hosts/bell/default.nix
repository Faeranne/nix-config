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
      allowedTCPPorts = [ 69 111 2049 4000 4001 4002 20048 ];
      allowedUDPPorts = [ 69 111 2049 4000 4001 4002 20048 ];
    };
  };

  services = {
    atftpd = {
      enable = true;
    };
    nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = ''
        /nix/store   192.168.1.0/24(ro,insecure,no_subtree_check)
        /export/persist 192.168.1.0/24(rw,insecure,no_subtree_check,anonuid=1001,anongid=1001)
      '';
    };
    udisks2 = {
      enable = true;
    };
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
    "/export/persist" = {
      device = "/persist/other";
      options = [ "bind" ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
