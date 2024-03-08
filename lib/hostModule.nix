with builtins;
{ inputs, base, hostname }: {...}: {
  networking = {
    hostName = hostname;
    hostId = base.hostId;
  };
  # Base elements
  boot.zfs.extraPools = if base.storage ? "zfs" then base.storage.zfs else [];
  boot.binfmt.emulatedSystems = if base ? "emulate" then base.emulate else [];
  virtualization.libvirtd.enable = (base ? "emulate");
  programs.virtmanager.enable = (base ? "emulate");

  # Configuration values. This should be replaced eventually.
  custom = {
    elements = base.elements;
    primaryNetwork = base.netdev;
    defaultDisk.rootDisk = base.storage.root;
  };
}
