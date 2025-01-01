# this file manages most of the security features I use.
{
  self,
  config,
  pkgs,
  ...
}: {
  # Needed to use yubikey stuff correctly
  services = {
    pcscd.enable = true;
  };

  boot = {
    # enables TPM2 support in systemd at boot time.
    initrd.systemd.tpm2.enable = true;
  };

  security = {
    # This is entirely used for managing tpm2 support.  I enable it to support
    # sealed secrets, hoping to use them with agenix eventually, but right now it
    # is just enabled to ensure any programs I want to use them can.  I control
    # the sealing secret for all my systems.
    tpm2 = {
      enable = true;
      tctiEnvironment.enable = true;
      pkcs11.enable = true;
    };
    # This is enabled to allow homeManger managed sway to be called from logind.
    # I don't remember the details of what this does, but I'll add more if it matters
    # to nix
    polkit = {
      enable = true;
    };
    pam = {
      services = {
        # swaylock doesn't work unless pam has this entry enabled.
        # simply setting it to a set triggers all the required entries, since
        # the pam nix module looks to see if it exists, not if it contains anything
        swaylock = {};
      };
      # This allows sshAgent to be used for sudo login.  Is only useful on servers
      # where an SSH Agent is used to connect
      sshAgentAuth = {
        enable = true;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      tpm2-tools
      tpm-tools
      tpmmanager
      yubikey-manager
    ];
  };
}
