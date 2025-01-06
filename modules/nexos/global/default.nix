{
  self,
  modules,
  ...
}: let
  inherit (self.inputs.nixpkgs.lib) concatStringsSep;
  inherit (builtins) filter;
  lib = self.inputs.nixpkgs.lib;
  eval = lib.evalModules {
    modules = modules ++ [
      (self.inputs.nixpkgs + "/nixos/modules/misc/assertions.nix")
      ./age.nix
      ./network.nix
      ./base.nix
    ];
    specialArgs = {
      inherit self lib;
    };
    class = "global";
  };
  config = eval.config;
  failedAssertions = map(x: x.message) (filter(x: !x.assertion) config.assertions);
in
  if failedAssertions != []
  then
    throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
  else
    config
