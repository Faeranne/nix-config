{pkgs, ...}: {
  home = {
    persistence."/persist/home/nina" = {
      directories = [
        ".passage"
        ".local/share/syncthing"
      ];
      files = [
      ];
    };
    packages = with pkgs; [
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
  };
}
