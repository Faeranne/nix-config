{pkgs, ...}: {
  home.packages = with pkgs; [
    wget
    htop
    dig
  ];
}
