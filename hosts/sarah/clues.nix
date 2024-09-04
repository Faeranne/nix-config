{self, config, ...}: let
  clues = builtins.fromJSON (builtins.readFile ./clues.json);
in {
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/${clues.bootID}";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };
  age.rekey.hostPubkey = clues.pubkey;
  systemd.network.links."99-primary" = {
    matchConfig.MAC = clues.mac;
  };
}
