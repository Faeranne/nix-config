systemBase: let
  cases = {
    amd = "x86_64-linux";
    intel = "x86_64-linux";
    rpi = "aarch64-linux";
    oracle = "aarch64-linux";
  };
  system = builtins.foldl' (b: a: 
    if (builtins.hasAttr a cases) then 
      (builtins.getAttr a cases)
    else 
      b
  ) "" systemBase.elements;
in
system
