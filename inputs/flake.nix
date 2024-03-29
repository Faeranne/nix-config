{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stardust-xr-server = {
      url = "github:StardustXR/server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: inputs;
}
