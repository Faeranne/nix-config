{
  id = 4;
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "rpi"
    "server"
    "impermanence"
    "lowmem"
    "netboot"
  ];
  # the machine-id of this system.
  hostId = "8bcb0597";
  # Primary network interface as reported by `ip addr`
  netdev = "eth0";
  # Root disk devices for this system.  Prefer `by-path` where possible,
  # but can be `by-id` if the path is not guarenteed, like on cloud servers.
  storage = {
    root = "/dev/mmcblk0";
  };
  # Users to add to the system. will build Home-Manager installs for this system too.
  users = [ "nina" ];
  sudo = [ "nina" ];
  # Elements used for security management.
  security = {
    pubkey = "age1ytw5hv3k50qnh6yn0ana3l932q7azkx0l2fg9zp9h02gknvqx4yq7yvcgl";
    preset = [
    ];
    generate = {
    };
  };
  netboot = {
    id = "C0A80171";
    mac = "01-dc-a6-32-ed-28-be";
  };
}
