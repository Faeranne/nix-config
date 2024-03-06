{config, pkgs, lib, ...}:
{
  config = lib.mkIf (builtins.elem "desktop" config.custom.elements) {
    dconf.settings = lib.mkIf (builtins.elem "gnome" config.custom.elements) {
      "org/gnome/desktop/wm/preferences".button-layout = "minimize,maximize,close";
    };
  };
}
