{pkgs, systemConfig, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isGraphical = isGnome || isKde;
  hasSteam = builtins.elem "steam" systemConfig.services;
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
    flatpak.enable = isGraphical;
  };
  programs = {
    zsh.enable = true;
  };
  programs.steam = {
    enable = hasSteam;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
    extest.enable = true;
  };
  environment.systemPackages = with pkgs; (
    [
      appimagekit
      appimage-run
      tpm2-tools
      tpm-tools
      tpmmanager
    ] ++
    (if (
      pkgs.system == "x86_64-linux"
    ) then (
      if isGraphical then [ 
        wineWowPackages.waylandFull
      ] else [ 
        wineWowPackages.staging 
      ]
    ) else [])
  );
}
