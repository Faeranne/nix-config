{pkgs, lib, userConfig, systemConfig, ...}:
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    forwardAgent = true;
  };
}
