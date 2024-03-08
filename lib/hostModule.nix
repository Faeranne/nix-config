with builtins;
systemBase: name: {...}: {
  networking = {
    hostName = name;
    hostId = systemBase.hostId;
  };
  boot.zfs.extraPools = if systemBase.storage ? "zfs" then systemBase.storage.zfs else [];
  custom = {
    elements = systemBase.elements;
    primaryNetwork = systemBase.netdev;
    defaultDisk.rootDisk = systemBase.storage.root;
  };
}
