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
  # the machine-id of this system.
  hostId = "586769c4";
  # Primary network interface as reported by `ip addr`
  primaryNetwork = "enp10s0";
  # Root disk devices for this system.  Prefer `by-path` where possible,
  # but can be `by-id` if the path is not guarenteed, like on cloud servers.
  rootDisk = "/dev/disk/by-id/nvme-eui.002538560140299a";
  # Users to add to the system. will build Home-Manager installs for this system too.
  users = [ "nina" ];
  modules = [
    ../../hardware/amd.nix
    ({...}:{
      networking.hostName = "sarah"; # Define your hostname.
      networking.hostId = "586769c4";

      custom = {
        elements = [ "amd" "desktop" "amdgpu" "gnome" "steam" ];
        primaryNetwork = "enp10s0";
        defaultDisk.rootDisk = "/dev/disk/by-id/nvme-eui.002538560140299a";
      };
    })
  ];
}
