{pkgs, ...}:
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    forwardAgent = true;
  };
  systemd.user.services.ssh-agent = {
    Service = {
      Environment = "SSH_ASKPASS=${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    };
  };
}
