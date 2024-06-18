inputs: let
  inherit (inputs.nixpkgs.lib) makeExtensible foldl;

  # Returns a list of valid files in `source` directory except for `default.nix`
  # Inputs:
  #   source: Path
  getNonDefaultFiles = source: (let
    files = builtins.readDir source;
  in
    (foldl (acc: name: 
      acc ++ (if (name != "default.nix" && ((builtins.getAttr name files) == "regular")) then [name] else [])
    ) [] (builtins.attrNames files))
  );
  #end getNonDefaultFiles

  lib = foldl (acc: input: acc.extend (import (./. + "/${input}"))) (makeExtensible (self: {inherit getNonDefaultFiles inputs;})) (getNonDefaultFiles ./.);
in
lib
