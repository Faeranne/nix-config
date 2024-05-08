{systemConfig, lib, ...}: let
  isServer = (builtins.elem "server" systemConfig.elements);
in {
  services.openssh = lib.mkIf isServer {
      enable = true;
      settings.PasswordAuthentication = false;
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
