{...}:{
  services.syncthing.enable = true;
  home = {
    persistence."/persist/home/nina" = {
      directories = [
        "Sync"
      ];
      files = [
      ];
    };
  };
}
