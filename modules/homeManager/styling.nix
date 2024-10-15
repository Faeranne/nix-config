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
      nixvim.enable = true;
      waybar.enable = true;
      yazi.enable = true;
      tmux.enable = true;
    };
  };
}
