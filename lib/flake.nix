{ inputs, mkUser, mkHost }: with builtins; let
  inherit (inputs.nixpkgs) lib;
  hostFolders = readDir ../hosts;
  hosts = foldl' (b: a: let
    include = if ((getAttr a hostFolders) == "directory") then [a] else [];
    res = b ++ include;
  in
    res
  ) [] (attrNames hostFolders);
in {
  nixosConfigurations = listToAttrs (map (hostname: let
    res = mkHost hostname;
  in {
    name = hostname;
    value = lib.nixosSystem res.configuration;
  }) hosts );
  agenix-rekey = inputs.agenix-rekey.configure {
    userFlake = self;
    nodes = self.nixosConfigurations;
  };
} // inputs.flake-utils.lib.eachDefaultSystem (system: rec {
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ agenix-rekey.overlays.default ];
  };
  devShells.default = pkgs.mkShell {
    packages = [ pkgs.agenix-rekey ];
  };
})
