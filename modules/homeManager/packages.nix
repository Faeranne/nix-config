{pkgs, ...}: {
  home.packages = with pkgs; [
    wget
    htop
    dig
    passage
    #NOTE: we're using the stable version for the moment till nixos/nixpkgs#309297
    # is merged.  libpcsclite is broken in the current unstable.
    stable.age-plugin-yubikey
    stable.age
    ruffle
    jackmix
    helvum
    ssh-agents
  ];
}
