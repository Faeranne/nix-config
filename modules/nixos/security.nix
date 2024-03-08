{ systemConfig, ... }: let
  localSystem = builtins.elem "local" systemConfig.elements;
in{
  services = {
    udev.packages = with pkgs; lib.mkIf localSystem [ yubikey-personalization ];
    pcscd.enable = true;
  };
}
