{utils, inputs}: hostname: username: inputs.home-manager.lib.homeManagerConfiguration (let
    systemConfig = utils.getHostConfig hostname;
    userConfig = utils.getUserConfig username;
    system = utils.getSystemFromBase systemConfig;
    module = utils.getUserModule username;
  in {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    extraSpecialArgs = {
      inherit utils userConfig systemConfig;
    };
    modules = [
      ../modules/homeManager
      module
    ];
  }
)
