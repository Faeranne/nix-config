{osConfig, ...}:{
  imports = [];

  home = {
    username = osConfig.users.users.nina.name or "nina";
    homeDirectory = osConfig.users.users.name.home or "/home/nina";
    stateVersion = "24.11";
  };
}
