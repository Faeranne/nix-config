{userConfig, ...}: {
  home = {
    stateVersion = "23.11";
    username = userConfig.username;
    homeDirectory = "/home/" + userConfig.username;
  };
}
