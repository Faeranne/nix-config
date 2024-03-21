{pkgs, lib, self, ...}:let
  keys = import ../../lib/getPubKeys.nix "nina";
in {
  users.extraUsers = {
    nixos.openssh.authorizedKeys.keys = keys;
    root.openssh.authorizedKeys.keys = keys;
  };
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  services = {
    pcscd.enable = true;
    sshd.enable = true;
  };
  environment.systemPackages = with pkgs; [
    gitFull
    neovim
    age
    agenix-rekey
    yubikey-manager
  ];

  system = {
    configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";
    stateVersion = "23.11"; # Did you read the comment?
  };

  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
