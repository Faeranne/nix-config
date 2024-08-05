{pkgs, ...}: {
  home.packages = with pkgs; [
    wget
    htop
    dig
    passage
    age-plugin-yubikey
    age
    ruffle
    jackmix
    helvum
    ssh-agents
    zip
    unzip
  ];
}
