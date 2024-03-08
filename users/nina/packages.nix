{pkgs, ...}: {
  home.packages = with pkgs; [
    wget
    htop
    dig
    yubikey-manager
    age-plugin-yubikey
    age
  ];
}
