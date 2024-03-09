{pkgs, systemConfig, ...}: let
  isDesktop = (builtins.elem "gnome" systemConfig.elements) || (builtins.elem "kde" systemConfig.elements);
in {
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };
  services = {
    flatpak.enable = isDesktop;
  };
  programs = {
    zsh.enable = true;
  };
}
