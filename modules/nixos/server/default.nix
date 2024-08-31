{config,...}: {
  services.openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
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
  networking.firewall.allowedTCPPorts = [ 22 ];
  systemd.network = {
    wait-online = {
      anyInterface = true;
    };
  };
}
