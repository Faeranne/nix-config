{pkgs, lib, userConfig, systemConfig, ...}:
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    forwardAgent = true;
  };
  systemd.user.sessionVariables = {
    SSH_ASKPASS = "${pkgs.ksshaskpass}/bin/ksshaskpass";
  };
}
