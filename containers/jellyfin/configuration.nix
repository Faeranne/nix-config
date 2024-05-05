# containerConfig is a block of container details, including configs for other containers.
# ```nix
# {
#   name = "container_name";
#   host = "container_host_name";
#   ports = { service = { tcp = 8096 }; };
#   paths = { host = {}; temp = []; }; # same from default.nix
#   containers = {
#     "name" = {
#       ip = "10.255.0.0"; # wireguard ip, so direct access.
#       fqdns = {
#         "service.domainname.tld" = "80"; # hostname = wireguard port.
#       };
#       neighbor = false; # is on the same defined host instance.
#     };
#   };
# }
# ```
{config, pkgs, containerConfig, ...}: {
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
  services.jellyfin = {
    enable = true;
  };
  system.stateVersion = "23.11";
}
