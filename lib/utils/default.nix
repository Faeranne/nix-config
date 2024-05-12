with builtins;
rec {
  #Defaults

  baseContainerIp = "10.200.0";
  wireguardBaseIp = "10.150";

  #miniUtils
  splitFileName = filename: (let
    res = match "(.*)\\..*" filename;
    name = elemAt res 0;
  in
    name
  );
  getFolders = source: (let
    folders = readDir source;
  in
    (foldl' (b: a: let
      include = if ((getAttr a folders) == "directory") then [a] else [];
      res = b ++ include;
      #this closes the let enclosure on `foldl'`'s first paramenter
    in
      res
      # we also have to pass an empty array as an initial value for foldl' to work with,
      # as well as the list to fold. In this case, I use `attrNames`, another builtin,
      # to get all the key names from `hostFolders`
    ) [] (attrNames folders))
  );
  getFiles = source: (let
    files = readDir source;
  in
    (foldl' (b: a: let
      include = if ((getAttr a files) == "regular") then [a] else [];
    in
      b ++ include
    ) [] (attrNames files))
  );

  #Host Tooling
  allHosts = getFolders ../../hosts;
  allHostConfigs = foldl' (res: host: {
    ${host} = getHostConfig host;
  } // res) {} allHosts;
  getHostConfig = hostname: (let
    originalConfig = import ../../hosts/${hostname};
    containerConfigs = getContainerConfigsForHost hostname;
  in
    { 
      inherit hostname; 
      containers = containerConfigs;
    } // originalConfig
  );
  getHostModule = hostname: import ../../hosts/${hostname}/configuration.nix;
  getSystemFromBase = config: import ../systemFromBase.nix config;

  #User Tooling
  allUsers = getFolders ../../users;
  getUserConfig = username: { inherit username; } // import ../../users/${username}/config.nix;
  getUserModule = username: import ../../users/${username};

  #Container Tooling
  ## mini
  getContainerFullName = host: name: "${host}-${name}";
  getContainerName = name: (let
    res = match "(.*)-(.*)" name;
  in
    elemAt res 1
  );
  getContainerHost = name: (let
    res = match "(.*)-(.*)" name;
  in
    elemAt res 0
  );

  allContainersForHost = hostname: (if (pathExists ../../hosts/${hostname}/containers) then (let
    files = getFiles ../../hosts/${hostname}/containers;
  in
    map (x: splitFileName x) (trace files files)
  ) else []);
  allContainers = (let
    hosts = allHosts;
  in
    concatMap (x: let
      containers = allContainersForHost x;
    in
      map (y: x+"-"+y) containers
    ) hosts
  );

  allContainerConfigs = (let
    hosts = allHosts;
  in
    foldl' (acc: host: (let
      configs = getContainerConfigsForHost host;
      containerNames = attrNames configs;
    in
      foldl' (acc2: container: {
        ${getContainerFullName host container} = configs.${container};
      } // acc2) {} containerNames
    ) // acc) {} hosts
  );

  getContainer = fullName: (let
    host = getContainerHost fullName;
    name = getContainerName fullName;
  in
    import ../../hosts/${host}/containers/${name}.nix
  );

  getContainerOrder = host:
    if (
      pathExists ../../hosts/${host}/containers.json
    ) then ( 
      fromJSON (readFile ../../hosts/${host}/containers.json)
    ) else [];

  getContainerConfigsForHost = host: (let
    order = getContainerOrder host;
    hostConfig = getHostConfig host;
    containerList = allContainersForHost host;
    checkContainers = (
      (toJSON 
        (sort (a: b: a < b) containerList)
      ) == (toJSON 
        (sort (a: b: a < b) order)
      )
    ) || (
      builtins.abort "hosts/${hostname}/containers.json does not contain exactly all containers from hosts/${hostname}/containers/.  Run `nix run .#updateContainers` to correct the list."
    );
    configs = foldl' (acc: container: let
      nextId = acc.currentId + 1;
      containerConfig = getContainer (getContainerFullName host container);
      containerIpEnd = acc.currentId+2;
      containerIp = "${baseContainerIp}.${toString containerIpEnd}";
      containerWgIp = "${wireguardBaseIp}.${toString hostConfig.id}.${toString containerIpEnd}";
      containerWgPort = containerIpEnd+35600;
    in
      acc // {
        ${container} = containerConfig // {inherit host; name = container; wireguardPort = containerWgPort; wireguardIp = containerWgIp; ip = containerIp; id = acc.currentId;};
        currentId = nextId;
      }
    ) {currentId = 0;} order;
  in
    if checkContainers then (removeAttrs configs ["currentId"]) else {}
  );
}
