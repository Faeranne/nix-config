{inputs, pkgs, ...}:{
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [
  ];
  programs.corectrl.enable = true;
}
