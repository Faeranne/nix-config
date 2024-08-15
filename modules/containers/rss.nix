{config, ...}:{
  imports = [
    (import ./template.nix "paperless")
  ];
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
