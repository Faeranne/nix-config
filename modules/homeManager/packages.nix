{pkgs, ...}: {
  home.packages = with pkgs; [
    wget
    htop
    dig
    passage
    age-plugin-yubikey
    age
  ];
}
