{inputs, pkgs, ...}:{
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
  ];
  programs.corectrl.enable = true;
  networking = {
    firewall = {
      allowedTCPPorts = [ 4747 4748 39595 ];
    };
  };
}
