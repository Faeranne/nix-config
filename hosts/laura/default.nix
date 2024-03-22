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
  netdev = "wpl108s0";
  # Root disk devices for this system.  Prefer `by-path` where possible,
  # but can be `by-id` if the path is not guarenteed, like on cloud servers.
  storage = {
    root = "/dev/disk/by-id/ata-SAMSUNG_SSD_PM871_M.2_2280_256GB_S208NXAGA31056";
  };
  # Users to add to the system. will build Home-Manager installs for this system too.
  users = [ "nina" ];
  sudo = [ "nina" ];
  # Elements used for security management.
  security = {
    pubkey = "age1x6yalmlph7h2de3flpk2a088cmhftpncv4czvu37j7fkdg6xtglse5p464";
  };
  # Service list
  services = [
  ];
  # extra modules to import
  modules = [
    ({pkgs,...}:{
      environment.systemPackages = [
        pkgs.libcamera
      ];
    })
  ];
}
