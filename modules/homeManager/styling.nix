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
      swaylock.enable = true;
      sway.enable = true;
      vesktop.enable = false;
      foot.enable = true;
      nixvim.enable = true;
      waybar.enable = true;
      yazi.enable = true;
      tmux.enable = true;
      firefox = {
        enable = true;
        profileNames = [ "default" ];
      };
    };
  };
}
