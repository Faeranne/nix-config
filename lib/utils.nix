(super: prev: let
  lib = super.inputs.nixpkgs.lib;
in {
  supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
  forAllSystemsBuildre = lib.genAttrs super.supportedSystems;
  splitFileName = filename: (let
    #Regex warning! There's gotta be a better way...
    res = builtins.match "(.*)\\..*" filename;
    #Trap for new players, nix requires a function to get a specific element of a list
    name = builtins.elemAt res 0;
  in
    name
  );
  getFolders = source: (let
    folders = builtins.readDir source;
  in
    (lib.foldl (b: a: let
      include = if ((builtins.getAttr a folders) == "directory") then [a] else [];
      res = b ++ include;
      #this closes the let enclosure on `foldl'`'s first paramenter
    in
      res
      # we also have to pass an empty array as an initial value for foldl' to work with,
      # as well as the list to fold. In this case, I use `attrNames`, another builtin,
      # to get all the key names from `hostFolders`
    ) [] (builtins.attrNames folders))
  );
  #Does the same as above but with files instead of subdirectories.
  getFiles = source: (let
    files = builtins.readDir source;
  in
    (lib.foldl (b: a: let
      include = if ((builtins.getAttr a files) == "regular") then [a] else [];
    in
      b ++ include
    ) [] (builtins.attrNames files))
  );
})
