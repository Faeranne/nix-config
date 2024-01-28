{ modulesPath, config, lib, pkgs, sops, ... }: {
  imports =
    [
      ../system/disks.nix
      ../system/base.nix
      ../system/oracle.nix
      ../services/ssh.nix
      ../services/podman.nix
      ../services/dns.nix
      ../services/traefik.nix
    ];
  _module.args = {
    rootDisk = "/dev/disk/by-path/pci-0000:18:00.0-scsi-0:0:0:1";
    primaryEthernet = "enp0s6";
  };
  networking.hostName = "oracle1"; # Define your hostname.
  networking.hostId = "badc65d2";

  system.stateVersion = "23.11"; # Did you read the comment?
  services.traefik.dynamicConfigOptions.http = {
    routers = {
      traefik = {
        rule = "Host(`traefik.oracle1.faeranne.com`)";
        service = "api@internal";
        entryPoints = [ "websecure" ];
        middlewares = [ "dash-auth" ];
      };
      dns = {
        rule = "Host(`ns1.faeranne.com`)";
        service = "dns";
        entryPoints = [ "websecure" ];
      };
    };
    services = {
      dns.loadBalancer.servers = [ {url = "http://10.200.1.4:5380";} ];
    };
  };
}
