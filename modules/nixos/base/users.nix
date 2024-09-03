{self, config, inputs, lib, ...}:{
  security.sudo.wheelNeedsPassword = true;

  users = {
    mutableUsers = false;
  };

  age = {
    generators = {
      # This generates ssh private keys.  This is primarily used for the git container, since it needs
      # to pass ssh commands through the host.
      sshkey = {pkgs, file, ...}: ''
        priv=$(mkfifo key && ((cat key ; rm key)&) && (echo y | ${pkgs.openssh}/bin/ssh-keygen -N "" -q -f key > /dev/null))
        cat key.pub > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
    };
  };

  home-manager = {
    backupFileExtension = "bak";
    sharedModules = [
      self.homeModules.default
      inputs.impermanence.nixosModules.home-manager.impermanence
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      systemConfig = config;
    };
  };
}
