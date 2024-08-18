{config, ...}:{
  imports = [
    (import ./template.nix "paperless")
  ];
  networking.wireguard.interfaces = {
    "wgjellyfin" = {
      ips = ["10.100.1.6/32"];
      listenPort = 51824;
    };
  };
  containers.paperless = {
    bindMounts = {
    };
    config = let 
      hostConfig = config;
    in {config, hostName, ...}: {
      imports = [
        ./base.nix
      ];
      networking = {
        firewall = {
          allowedTCPPorts = [ config.services.nginx.port ];
        };
      };
      services.freshrss = {
        enable = true;
        baseUrl = "https://${hostName}";
        defaultUser = "faeranne";
        passwordFile = "/run/secrets/freshrss";
      };
    };
  };
}
