{self, config, inputs, lib, ...}:{
  # This madates that the `sudo` command
  # requires a password.
  security.sudo.wheelNeedsPassword = true;

  users = {
    # /etc/passwd and /etc/groups get completely dropped
    # and reset on each activation.  Means `passwd` and
    # `useradd` don't work as expected, but ensures
    # any issues with uids show up eventually
    mutableUsers = false;
  };

  age = {
    generators = {
      # This generates ssh private keys.  This is primarily used for the git container, since it needs
      # to pass ssh commands through the host. See modules/nixos/base/security.nix for more details
      sshkey = {pkgs, file, ...}: ''
        priv=$(mkfifo key && ((cat key ; rm key)&) && (echo y | ${pkgs.openssh}/bin/ssh-keygen -N "" -q -f key > /dev/null))
        cat key.pub > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
    };
  };
  environment.createDir = [
    {
      path = "/persist/home";
      owner = "nobody:users";
      permissions = "775"; 
    }
  ];

  home-manager = {
    # If a config file or directory alread exists and *isn't* managed by home-manager
    # this tells home-manager what to name it to so it isn't permanently lost.
    backupFileExtension = "bak";
    # Each of these is a module used by *every* home-manager instance for a host.
    sharedModules = [
      # This is our modules/homeManager/base.nix module, as defined by
      # modules/homeManager/default.nix
      self.homeModules.default
      # This introduces impermanence to home directories too.
      inputs.impermanence.nixosModules.home-manager.impermanence
    ];
    # Tells home manager to allow global packages to be seen by users.
    useGlobalPkgs = true;
    # Lets home manager manage the users personal package list.
    useUserPackages = true;
    # Defines other things that can be included in the argument set for
    # each module.  Same as specialArgs for hosts.
    extraSpecialArgs = {
      inherit inputs;
      # ensures we have a copy of the system config to use in user modules.
      # for example, for seeing if we are a desktop system
      systemConfig = config;
    };
  };
}
