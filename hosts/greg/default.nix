{
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "intel"
    "server"
    "impermanence"
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
  sudo = [ "nina" ];
  # Elements used for security management.
  security = {
    pubkey = "age1ytw5hv3k50qnh6yn0ana3l932q7azkx0l2fg9zp9h02gknvqx4yq7yvcgl";
  };
}
