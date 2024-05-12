{systemConfig, lib, ...}: let
  isServer = (builtins.elem "server" systemConfig.elements);
in {
  services.openssh = lib.mkIf isServer {
      enable = true;
      settings.PasswordAuthentication = false;
      #TODO: Right now this ignores non-impermanent systems.
      # Gotta set `path` correctly for non-impermanent systems.
      # As of this moment none of my systems qualify, so it's a
      # todo.
      hostKeys = [
        {
          bits = 4096;
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
  };
  networking.firewall.allowedTCPPorts = lib.mkIf isServer [ 22 ];
}
