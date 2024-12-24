{config, ...}:{
  environment = {
    persistence."/persist" = {
      directories = [
        config.services.syncthing.dataDir
      ];
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8385 ];
  };
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8385";
  };
}
