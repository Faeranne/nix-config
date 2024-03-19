{pkgs, lib, ...}:let
  keys = import ../../lib/getPubKeys.nix "nina";
in {
  users.extraUsers.nixos.openssh.authorizedKeys.keys = keys;
  users.extraUsers.root.openssh.authorizedKeys.keys = keys;
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
}
