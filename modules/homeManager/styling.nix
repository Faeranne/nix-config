{userConfig, systemConfig, ...}:let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isSway = (builtins.elem "sway" systemConfig.elements);
  isGraphical = isGnome || isKde || isSway;
in {
  stylix = {
    enable = isGraphical;
    autoEnable = false;
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
