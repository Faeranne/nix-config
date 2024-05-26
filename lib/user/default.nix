inputs: let
  utils = import ../utils.nix;
  host = ../host;
in {
  generateUserForHost = hostname: username: inputs.home-manager.lib.homeManagerConfiguration (let
      systemConfig = host.getHostConfig hostname;
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
  getAllKeys = user: let
    userConfig = import ../users/${user}/config.nix;
    hosts = builtins.attrNames userConfig.ssh_keys.hosts;
    keys = builtins.foldl' (acc: name: let
      host = builtins.getAttr name userConfig.ssh_keys.hosts;
      keyNames = builtins.attrNames host;
      keyReturns = builtins.foldl' (acc2: keyName: let
        entry = (builtins.getAttr keyName host);
      in
        acc2 ++ [ entry.pub ]
      ) [] keyNames;
    in
      acc ++ keyReturns
    ) [] hosts;
  in
    keys;
}
