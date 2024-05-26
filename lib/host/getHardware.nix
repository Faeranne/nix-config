with builtins;
let
  utils = import ./utils;
  hardwareDir = readDir ../modules/hardware;
  hardware = foldl' (b: a: let
    include = if ((getAttr a hardwareDir) == "regular") then [(utils.splitFileName a)] else [];
    res = b ++ include;
  in
    res
  ) [] (attrNames hardwareDir);
in
elements: let
  hardwareModules = foldl' (b: a: let
    include = if (elem a elements) then [ ../modules/hardware/${a}.nix ] else [];
    res = b ++ include;
  in 
    res
  ) [] hardware;
in
hardwareModules
