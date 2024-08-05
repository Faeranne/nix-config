{systemConfig, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    opacity = {
      popups = 0.9;
      terminal = 0.8;
    };
    targets = {
      firefox.profileNames = [ "default" ];
      swaylock.enable = true;
      vesktop.enable = false;
    };
  };
}
