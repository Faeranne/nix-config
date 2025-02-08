{
  inputs,
  ...
}:{
  imports = [
    inputs.nur.modules.nixos.default
  ];
  nixpkgs.overlays = [
    inputs.nur.overlay
  ];
}
