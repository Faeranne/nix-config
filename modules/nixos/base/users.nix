{self, config, inputs, ...}:{
  security.sudo.wheelNeedsPassword = true;

  users = {
    mutableUsers = false;
  };

  home-manager = {
    backupFileExtension = "bak";
    sharedModules = [
      self.homeManagerModules.default
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      systemConfig = config;
    };
  };
}
