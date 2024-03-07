{config, lib, pkgs, ...}:
{
  config = lib.mkIf (builtins.elem "steam" config.custom.elements) {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession.enable = true;
      };
    };
    environment.systemPackages = with pkgs; [
      steam-run
    ];
  };
}
