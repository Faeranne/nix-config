{
  config,
  ...
}:let
  hostKeys = if config.environment ? persist then [
    {
      bits = 4096;
      path = "/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
    {
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ] else [];
in {
  security.pam = {
    sshAgentAuth.enable = true;
  };
  services.openssh = {
    inherit hostKeys;
    enable = true;
    settings.PasswordAuthentication = true;
  };
  networking.firewall.allowedTCPPorts = [
    22
  ];
  systemd.network = {
    wait-online = {
      anyInterface = true;
    };
  };
}
