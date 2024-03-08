{
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "amd"
    "desktop"
    "amdgpu"
    "gnome"
    "steam"
  ];
  # architectures to emulate
  emulate = [ "aarch64-linux" ];
  # the machine-id of this system.
  hostId = "586769c4";
  # Primary network interface as reported by `ip addr`
  netdev = "enp10s0";
  # Root disk devices for this system.  Prefer `by-path` where possible,
  # but can be `by-id` if the path is not guarenteed, like on cloud servers.
  storage = {
    root = "/dev/disk/by-id/nvme-eui.002538560140299a";
  };
  # Users to add to the system. will build Home-Manager installs for this system too.
  users = [ "nina" ];
  sudo = [ "nina" ];
  # Service list
  services = [
  ];
  # extra modules to import
  modules = [
    ({...}:{
    })
  ];
}
