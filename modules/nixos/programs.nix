{pkgs, systemConfig, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isSway = (builtins.elem "sway" systemConfig.elements);
  isGraphical = isGnome || isKde || isSway;
  hasSteam = builtins.elem "steam" systemConfig.elements;
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
    #gamescopeSession.enable = true;
    adb = {
      enable = true;
    };
  };
  hardware.steam-hardware.enable = hasSteam;
  environment.systemPackages = with pkgs; (
    [
      appimagekit
      appimage-run
      tpm2-tools
      tpm-tools
      tpmmanager
      p7zip
      #NOTE: we're using the stable version for the moment till nixos/nixpkgs#309297
      # is merged.  libpcsclite is broken in the current unstable.
      stable.yubikey-manager
    ] ++
    (if (
      pkgs.system == "x86_64-linux"
    ) then (
      if isGraphical then [ 
        wineWowPackages.waylandFull
        lxqt.lxqt-policykit
      ] else [ 
        wineWowPackages.stagingFull
      ]
    ) else [])
  );
}
