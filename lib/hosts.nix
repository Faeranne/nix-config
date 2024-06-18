(super: prev: {
  allHosts = super.getFolders ../hosts;

  allHostConfigs = super.inputs.nixpkgs.lib.foldl (res: host: {
    ${host} = super.getHostConfig host;
  } // res) {} super.allHosts;

  getHostConfig = hostname: (let
    originalConfig = import ../hosts/${hostname};
    #containerConfigs = getContainerConfigsForHost hostname;
  in
    { 
      inherit hostname; 
    #  containers = containerConfigs;
    } // originalConfig
  );
})
