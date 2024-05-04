{pkgs, ...}: {
  home.packages = with pkgs; [
    wget
    htop
    dig
    passage
    stable.age-plugin-yubikey
    stable.age
    ruffle
    jackmix
    helvum
    ssh-agents
  ];
}
