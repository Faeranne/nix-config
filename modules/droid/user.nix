{...}: {
  home-manager = {
    config = ../homeManager;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };
}
