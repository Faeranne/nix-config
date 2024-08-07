{
  id = 0;
  # base elements to implement on this host.
  # most are defined in `systems/`
  elements = [ 
    "intel"
    "nvidiagpu"
    "server"
    "impermanence"
    "traefik"
    "containers"
    "nfs"
    #"netboot-server"
  ];
  # architectures to emulate
  emulate = [ "aarch64-linux" ];
  # the machine-id of this system.
  hostId = "ccd933cc";
  # Primary network interface as reported by `ip addr`
  netdev = "eno1";
  # Networking stuff
  net = {
    ip = "192.168.1.10";
    url = "greg.home.faeranne.com";
    mac = "94:de:80:67:df:1a";
  };
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
    preset = [
      "openvpn_pass"
      "openvpn_user"
      "mullvad_address"
      "github_runner1"
    ];
    generate = {
      freshrss = {
        script = "passphrase";
        tags = [ "pregen" ];
      };
      paperless_superuser = {
        script = "passphrase";
        tags = [ "pregen" ];
      };
      mullvad = {
        script = "wireguard";
        tags = [ "fixed" ];
      };
    };
  };
}
