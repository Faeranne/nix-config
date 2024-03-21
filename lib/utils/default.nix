with builtins;
{
  splitFileName = filename: (let
    res = match "(.*)\\..*" filename;
    name = elemAt res 0;
  in
    name
  );
  getFolders = source: let
    folders = readDir source;
    results = foldl' (b: a: let
      include = if ((getAttr a folders) == "directory") then [a] else [];
      res = b ++ include;
      #this closes the let enclosure on `foldl'`'s first paramenter
    in
      res
      # we also have to pass an empty array as an initial value for foldl' to work with,
      # as well as the list to fold. In this case, I use `attrNames`, another builtin,
      # to get all the key names from `hostFolders`
    ) [] (attrNames folders);
  in
    results;
}
