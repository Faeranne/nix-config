{pkgs, ...}:{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = with pkgs; [
        gamescope
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
      gamescopeSession = {
        enable = true;
        env = {
          WLR_RENDERER = "vulkan";
          DXVK_HDR = "1";
          ENABLE_GAMESCOPE_WSI = "1";
          WINE_FULLSCREEN_FSR = "1";
          SDL_VIDEODRIVER = "x11";
        };
        args = [
          "--xwayland-count 2"
          "--expose-wayland"
          "-e"
          "--steam"
          "--adaptive-sync"
          "--hdr-enabled"
          "--hdr-itm-enable"
          "--output-width 2560"
          "--output-height 1440"
        ];
      };
    };
    gamescope = {
      enable = true;
    };
  };
  hardware.steam-hardware.enable = true;
}
