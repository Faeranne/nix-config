{
  id = 4;
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "rpi"
    "server"
    "impermanence"
   #"lowmem"
    "netboot"
  ];
  # the machine-id of this system.
  hostId = "9d6541c6";
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
    pubkey = "age1j4vfw8e0vv2p86hz974t3y6gzk5ey8q3vlfutdsd2a56tncakemsf9rzrz";
    preset = [
    ];
    generate = {
    };
  };
}
