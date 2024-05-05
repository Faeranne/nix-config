with builtins;
rec {
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
  allHosts = getFolders ../../hosts;
  allUsers = getFolders ../../users;
  allHostConfigs = foldl' (res: host: {
    ${host} = getHostConfig host;
  } // res) {} allHosts;
  getHostConfig = hostname: { inherit hostname; } // import ../../hosts/${hostname};
  getHostModule = hostname: import ../../hosts/${hostname}/configuration.nix;
  getUserConfig = username: { inherit username; } // import ../../users/${username}/config.nix;
  getUserModule = username: import ../../users/${username};
  getContainerConfig = name: { inherit name; } // import ../../containers/${name};
  getContainerModule = name: import ../../containers/${name}/configuration.nix;
  getSystemFromBase = config: import ../systemFromBase.nix config;
  createContainerForHost = import ./createContainerHost.nix;
}
