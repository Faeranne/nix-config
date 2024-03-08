{
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "intel"
    "server"
  ];
  # architectures to emulate
  emulate = [ "aarch64-linux" ];
  # the machine-id of this system.
  hostId = "ccd933cc";
  # Primary network interface as reported by `ip addr`
  netdev = "eno1";
  # Root disk devices for this system.  Prefer `by-path` where possible,
  # but can be `by-id` if the path is not guarenteed, like on cloud servers.
  storage = {
    root = "/dev/disk/by-path/pci-0000:00:1a.0-usb-0:1.1:1.0-scsi-0:0:0:0";
    zfs = [ "Storage" ];
  };
  # Users to add to the system. will build Home-Manager installs for this system too.
  users = [ "nina" ];
  # extra modules to import
  modules = [
    ({...}:{
    })
  ];
}
