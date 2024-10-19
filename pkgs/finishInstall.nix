{
  zfs,
  jq,
  writeScriptBin
}: writeScriptBin ''
  set -e
  SYSTEM=$1
  URL=https://git.faeranne.com/faeranne/nix-config
  nix flake show $URL --json  | ${jq}/bin/jq .nixosConfigurations.proto_$SYSTEM | grep type
  ${zfs}/bin/zpool import zroot
  mount -t zfs -o zfsutil zroot/root /mnt
  mkdir /mnt/{nix,persist,boot}
  mount /dev/disk/by-uuid/$DISK /mnt/boot
  mount -t zfs -o zfsutil zroot/nix /mnt/nix
  mount -t zfs -o zfsutil zroot/persist /mnt/persist
  nixos-install --flake $URL#proto_$SYSTEM --option extra-features "flakes nix-command ca-derivations" --no-root-password --no-copy-cache
''
