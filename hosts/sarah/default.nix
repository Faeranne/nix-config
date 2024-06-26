{
  id = 3;
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "amd"
    "desktop"
    "impermanence"
    "amdgpu"
    "sway"
    "virtualization"
    "rgb"
    "steam"
    "bluetooth"
  ];
  # architectures to emulate
  emulate = [ "aarch64-linux" ];
  # the machine-id of this system.
  hostId = "586769c4";
  # Primary network interface as reported by `ip addr`
  netdev = "enp10s0";
  ip = "192.168.1.80";
  # Root disk devices for this system.  Prefer `by-path` where possible,
  # but can be `by-id` if the path is not guarenteed, like on cloud servers.
  storage = {
    root = "/dev/disk/by-id/nvme-eui.002538560140299a";
  };
  # Users to add to the system. will build Home-Manager installs for this system too.
  users = [ "nina" ];
  sudo = [ "nina" ];
  # Elements used for security management.
  security = {
    pubkey = "age185avxte33jvaexyl5292nczj3drlhc5dnyv8svyyy8u4l0tfgpksz6encl";
  };
}
