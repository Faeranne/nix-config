{userConfig, ...}:{
  stylix = {
    enable = true;
    autoEnable = true;
    image = userConfig.wallpaper;
    polarity = "dark";
    opacity = {
      popups = 0.9;
      terminal = 0.8;
    };
    targets = {
      firefox.profileNames = [ "default" ];
    };
  };
}
