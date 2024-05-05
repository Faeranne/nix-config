#create SimpleContainerConfig to use for contaiernConfig.containers
h
host: container: let
  inherit (import ./.) getHostConfig getContainerConfig getContainerModule allHostConfigs;
  hostConfig = getHostConfig host;
  hostContainerConfig = hostConfig.containers.${container};
  containerConfig = getContainerConfig hostContainerConfig.type;
in {lib, ...}: let
  mounts = (lib.concatMapAttrs (name: hostPath: let
    containerPath = containerConfig.paths.host.${name};
  in {
    ${containerPath} = {
      inherit hostPath;
      isReadOnly = false;
    };
  }) hostContainerConfig.paths);
  bindMounts = mounts;
  containers = lib.concatMapAttrs (contHost: attrs: 
    lib.concatMapAttrs (thisContainer: attrs2: if (thisContainer != container) then {
      "${contHost}.${thisContainer}" = {
        inherit (attrs2) ip forwardPorts;
        neighbor = (host == contHost);
      };
    } else {}) attrs.containers
  ) allHostConfigs;
  tcpPorts = builtins.foldl' (acc: service: (if (builtins.hasAttr "tcp" containerConfig.ports.${service}) then [
    containerConfig.ports.${service}.tcp
  ] else [] ) ++ acc) [] (builtins.attrNames containerConfig.ports);
  udpPorts = builtins.foldl' (acc: service: (if (builtins.hasAttr "udp" containerConfig.ports.${service}) then [
    containerConfig.ports.${service}.udp
  ] else [] ) ++ acc) [] (builtins.attrNames containerConfig.ports);
in {
  containers."${container}" = {
    # inherit bindMounts;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "brCont";
    localAddress = hostContainerConfig.localIp;
    config = {lib, ...}:{
      imports = [
        (getContainerModule container)
      ];
      networking = {
        useHostResolvConf = lib.mkForce false;
        defaultGateway = "10.150.1.1";
        firewall = {
          enable = true;
          allowedTCPPorts = tcpPorts;
          allowedUDPPorts = udpPorts;
        };
      };
    };
    specialArgs = {
      containerConfig = {
        name = container;
        host = host;
        inherit (containerConfig) paths ports;
        inherit containers;
      };
    };
  };
}
