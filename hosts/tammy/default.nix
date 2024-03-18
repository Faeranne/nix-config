{
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "intel"
    "laptop"
    "impermanence"
    "gnome"
  ];
  # architectures to emulate
  emulate = [ "aarch64-linux" ];
  # the machine-id of this system.
  hostId = "76dc8f17";
  # Primary network interface as reported by `ip addr`
  netdev = "wpl6s0";
  # Root disk devices for this system.  Prefer `by-path` where possible,
  # but can be `by-id` if the path is not guarenteed, like on cloud servers.
  storage = {
    root = "/dev/disk/by-id/ata-KINGSTON_SV300S37A120G_50026B733201BED6";
  };
  # Users to add to the system. will build Home-Manager installs for this system too.
  users = [ "nina" ];
  sudo = [ "nina" ];
  # Elements used for security management.
  security = {
    pubkey = "";
  };
  # Service list
  services = [
  ];
  # extra modules to import
  modules = [
    ({...}:{
    })
  ];
}
