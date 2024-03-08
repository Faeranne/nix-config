{
  elements = [ "intel" "server" ];
  emulate = [ "aarch64-linux" ];
  users = [ "nina" ];
  hostId = "ccd933cc";
  primaryNetwork = "eno1";
  storage = {
    root = "/dev/disk/by-path/pci-0000:00:1a.0-usb-0:1.1:1.0-scsi-0:0:0:0";
    zfs = [ "Storage" ];
  };
  paths = {
    vols = "/Storage/volumes";
    media = "/Storage/media";
  };
  modules = [
    ({...}:{
      networking.hostName = "greg"; # Define your hostname.
      networking.hostId = "ccd933cc";
      custom = {
        elements = [ "intel" "server" ];
        primaryNetwork = "eno1";
        defaultDisk.rootDisk = "/dev/disk/by-path/pci-0000:00:1a.0-usb-0:1.1:1.0-scsi-0:0:0:0";
      };
    })
  ];
}
