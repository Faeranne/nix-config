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
}
