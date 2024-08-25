{self, config, inputs, ...}:{
  security.sudo.wheelNeedsPassword = true;

  users = {
    mutableUsers = false;
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
