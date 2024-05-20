with builtins;
rec {
  #Defaults

  baseContainerIp = "10.200.0";
  wireguardBaseIp = "10.150";

  #miniUtils
  #This splits a given file name off of it's extension and returns just the first part.
  #NOTE: this breaks with filenames with more than one . seperator.
  splitFileName = filename: (let
    #Regex warning! There's gotta be a better way...
    res = match "(.*)\\..*" filename;
    #Trap for new players, nix requires a function to get a specific element of a list
    name = elemAt res 0;
  in
    name
  );
  #Returns a string list containing the subdirectory names in a directory.
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
  #Does the same as above but with files instead of subdirectories.
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
  #Just get the names of all defined hosts.
  allHosts = getFolders ../../hosts;

  #Get a set containing each host's config.
  #This can be useful elsewhere for cross-host
  #config, but so far is unused.
  allHostConfigs = foldl' (res: host: {
    ${host} = getHostConfig host;
  } // res) {} allHosts;

  #Return the config of a given host.  Note that this contains more than just
  #the host's `default.nix` file, since a few things are inherited from other
  #configs and of course the hostname too.
  getHostConfig = hostname: (let
    originalConfig = import ../../hosts/${hostname};
    containerConfigs = getContainerConfigsForHost hostname;
  in
    { 
      inherit hostname; 
      containers = containerConfigs;
    } // originalConfig
  );

  #Returns the nixos module for a given host.  Just a normalizing function.
  getHostModule = hostname: import ../../hosts/${hostname}/configuration.nix;

  #Returns the system from a given host config.  Check the file for more details.
  getSystemFromBase = config: import ../systemFromBase.nix config;

  #User Tooling

  #Get all usernames defined.
  allUsers = getFolders ../../users;

  #Similar to `getHostConfig` but for users.
  getUserConfig = username: { inherit username; } // import ../../users/${username}/config.nix;

  #Ditto
  getUserModule = username: import ../../users/${username};

  #Container Tooling
  ## mini

  #Convience function for getting the canonical name of a container based on
  #it's name and it's host's name.
  getContainerFullName = host: name: "${host}-${name}";

  #Break the canonical container name into the container's name.
  getContainerName = name: (let
    res = match "(.*)-(.*)" name;
  in
    elemAt res 1
  );

  #Break the canonical container name into the host's name.
  getContainerHost = name: (let
    res = match "(.*)-(.*)" name;
  in
    elemAt res 0
  );

  #Get every container defined for a host.  This is used for verifying the 
  #`containers.json` file.
  allContainersForHost = hostname: (if (pathExists ../../hosts/${hostname}/containers) then (let
    files = getFiles ../../hosts/${hostname}/containers;
  in
    map (x: splitFileName x) (trace files files)
  ) else []);

  #This may not be used anymore... keeping the unused code till I'm certain.
  #Pretty sure it's superceeded by the below function.
  /*
  allContainers = (let
    hosts = allHosts;
  in
    concatMap (x: let
      containers = allContainersForHost x;
    in
      map (y: x+"-"+y) containers
    ) hosts
  );
  */

  #Get every container config as a "canonical container name" -> config pairing
  #This gets passed to each host to allow hosts and containers to reference
  #container ips and other such details.
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

  
  #Get the container config data based on a canonical container name.
  getContainer = fullName: (let
    host = getContainerHost fullName;
    name = getContainerName fullName;
  in
    import ../../hosts/${host}/containers/${name}.nix
  );
  
  #Get the expected order of containers from `containers.json`.
  #This is ultimatly used to define containers and derive
  #their ID value, so it's important that it exists and contains
  #exactly the containers in `contianers/` for a host. otherwise
  #we can end up with a container without an id, or a container
  #without a config.
  getContainerOrder = host:
    if (
      pathExists ../../hosts/${host}/containers.json
    ) then ( 
      fromJSON (readFile ../../hosts/${host}/containers.json)
    ) else [];

  #Returns every possible container config for a given host,
  #based on `containers.json`
  getContainerConfigsForHost = host: (let
    order = getContainerOrder host;
    hostConfig = getHostConfig host;
    containerList = allContainersForHost host;
    #this ensures the container in `containers/` matches the
    #list in `containers.json`, so that we aren't caught off
    #guard when a container is added or removed.
    #TODO: eventually this should also yell if the number of
    #containers is over 253, since that will break the ip
    #space.  Unlikely to ever happen, but something to be 
    #aware of.
    checkContainers = (
      (toJSON 
        (sort (a: b: a < b) containerList)
      ) == (toJSON 
        (sort (a: b: a < b) order)
      )
    ) || (
      builtins.abort "hosts/${host}/containers.json does not contain exactly all containers from hosts/${host}/containers/.  Run `nix run .#updateContainers` to correct the list."
    );
    #Container ID time.  This handles assigning the ids based
    #on the container's order in `containers.json`, as well as
    #defining things like the wireguardip, the port wireguard 
    #will end up listening on, and so on.  This ensures that
    #container ip addresses remain consistant when the actual
    #container lists change, since otherwise it would generate
    #ids in alphabetical order, which may change a container's
    #ip address.
    configs = foldl' (acc: container: let
      #`currentId` handles the id index, since there is no
      #index value passed from `foldl'`.
      nextId = acc.currentId + 1;
      containerConfig = getContainer (getContainerFullName host container);
      #We bump the Ip address up 2 since ids start at 0, and 1 is occupied by
      #the host.
      containerIpEnd = acc.currentId+2;
      containerIp = "${baseContainerIp}.${toString containerIpEnd}";
      containerWgIp = "${wireguardBaseIp}.${toString hostConfig.id}.${toString containerIpEnd}";
      containerWgPort = containerIpEnd+35600;
    in
      acc // {
        ${container} = containerConfig // {inherit host; name = container; wireguardPort = containerWgPort; wireguardIp = containerWgIp; ip = containerIp; id = acc.currentId;};
        #When passing forward, we update `currentId`.
        currentId = nextId;
      }
      #Gotta define currentId as 0 to start off with.
    ) {currentId = 0;} order;
  in
    #We do the actual check here, then remember to remove `currentId` from the set.
    #since all evaluation is lazy, we don't have to worry about the above evaluating first if
    #the check fails.
    if checkContainers then (removeAttrs configs ["currentId"]) else {}
  );

  /*
    This set of values covers gathering and handling netboot stuff.
  */
  getNetbootConfigs = foldl' (res: host: let
    config = getHostConfig host;
    isNetboot = (builtins.elem "netboot" config.elements);
  in (if isNetboot then {
    ${host} = config;
  } else {}) // res) {} allHosts;
}
