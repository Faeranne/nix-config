{pkgs, lib, userConfig, systemConfig, ...}:
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    forwardAgent = true;
  };
  systemd.user.services.ssh-agent = {
    ENVIRONMENT = {
      SSH_ASKPASS = "${pkgs.ksshaskpass}/bin/ksshaskpass";
    };
  };
}
