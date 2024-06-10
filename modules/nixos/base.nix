{inputs, self, systemConfig, pkgs, ...}: {
  
  system = {
    configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";
    stateVersion = "23.11"; # Did you read the comment?
    # Since nixos.label is only really used when running a boot switch, which doesn't happen
    # normally in a dirty repo, I'm only including it.  Dirty just reminds me that I intentionally
    # escaped my normal methods
    nixos.label = if self ? rev then "git-rev ${builtins.substring 0 8 self.rev}" else "dirty";
  };
  # Base elements

  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [ "https://yazi.cachix.org" ];
      extra-trusted-public-keys = [ "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerdfonts
  ];
}
