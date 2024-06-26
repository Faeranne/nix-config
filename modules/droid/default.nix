{inputs, ...}:{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  system.stateVersion = "24.05";
}
