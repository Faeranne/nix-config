{ config, lib, pkgs, inputs, ... }:
let
  elements = config.custom.elements;
  cfg = config.custom.tor;
  inherit (lib) types mkOption;
  sops = inputs.sops;
in
{
  options.custom.tor = with types; {
    local = mkOption {
      description = "Container IP.";
      type = str;
    };
  };
  config = lib.mkIf (builtins.elem "media" elements) {
    sops.secrets.openvpn_user = {
      sopsFile = ../../secrets/gluetun.yaml;
      mode = "0440";
      owner = "services";
    };
    sops.secrets.openvpn_password = {
      sopsFile = ../../secrets/gluetun.yaml;
      mode = "0440";
      owner = "services";
    };
      
    virtualisation.oci-containers.containers = {
      gluetun = {
        image = "qmcgaw/gluetun";
        hostname = "gluetun";
        ports = [
          "9091:9091"
        ];
        environment = {
          PUID="${toString config.users.users.services.uid}";
          VPN_SERVICE_PROVIDER= "private internet access";
          SERVER_REGIONS="Switzerland";
          TZ="America/Indiana";
          VPN_PORT_FORWARDING="on";
          VPN_PORT_FORWARDING_STATUS_FILE="/mnt/gluetun_port/forwarded_port";
        };
        volumes = [
          "${config.custom.paths.vols}/gluetun:/gluetun"
          "${config.sops.secrets.openvpn_user.path}:/run/secrets/openvpn_user"
          "${config.sops.secrets.openvpn_password.path}:/run/secrets/openvpn_password"
          "${config.custom.paths.vols}/gluetun_port:/mnt/gluetun_port"
        ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun:/dev/net/tun"
          "--ip=${cfg.local}"
        ];
        autoStart = true;
      };
      transmission = {
        image = "lscr.io/linuxserver/transmission:latest";
        environment = {
          PUID="${toString config.users.users.services.uid}";
          TZ="America/Indiana";
          TRANSMISSION_WEB_HOME="/transmission";
        };
        volumes = [
          "${config.custom.paths.vols}/transmission:/config"
          "${config.custom.paths.vols}/transmission:/downloads"
          "${config.custom.paths.vols}/gluetun_port:/mnt/gluetun_port"
        ];
        dependsOn = [ "gluetun" ];
        extraOptions = [
          "--network=container:gluetun"
        ];
        autoStart = true;
      };
    };
  };
}
