{
  self,
  ...
}: let
  localCfg = builtins.fromJSON (builtins.readFile ./config.json);
in {
  imports = with self.nixosModules; [
    base
    server
    extras.storage
    self.userModules.nina
  ];

  nexos = {
    info = {
      name = "eve";
      configPath = ./config.json;
    };
    hardware.cpu.intel.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
