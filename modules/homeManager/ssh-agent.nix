{pkgs, ...}:
{
  services.ssh-agent.enable = true;
  home = {
    persistence."/persist/home/nina" = {
      directories = [
      ];
      files = [
        ".ssh/known_hosts"
      ];
    };
  };
  programs.ssh = {
    forwardAgent = true;
  };
  systemd.user.services.ssh-agent = {
    Service = {
      Environment = "SSH_ASKPASS=${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    };
  };
}
