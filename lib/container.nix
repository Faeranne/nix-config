containerConfig: let
  #${container} = containerConfig // {inherit host; wireguardPort = containerWgPort; wireguardIp = containerWgIp; ip = containerIp; id = acc.currentId;};
  portNames = builtins.attrNames containerConfig.network.ports;
  tcpPorts = builtins.foldl' (acc: portName: let
    isTcp = containerConfig.network.ports.${portName}.type == "tcp";
  in
    if isTcp then [ containerConfig.network.ports.${portName}.port ] else []
  ) [] portNames;
  udpPorts = builtins.foldl' (acc: portName: let
    isUdp = containerConfig.network.ports.${portName}.type == "udp";
  in
    if isUdp then [ containerConfig.network.ports.${portName}.port ] else []
  ) [] portNames;
in {config, ...}:let
  secretMounts = if (builtins.hasAttr "secrets" containerConfig) then (builtins.foldl' (acc: secret: {
    "/run/secrets/${secret}" = {
      hostPath = "${config.age.secrets."${secret}".path}";
      isReadOnly = true;
    };
  }//acc) {} containerConfig.secrets) else {};
  bindMounts = containerConfig.bindMounts // secretMounts;
in {
  containers = {
    ${containerConfig.name} = {
      tmpfs = if (builtins.hasAttr "tmpfs" containerConfig) then containerConfig.tmpfs else [];
      inherit bindMounts;
      autoStart = true;
      privateNetwork = true;
      restartIfChanged = true;
      localAddress = "${containerConfig.ip}/16";
      hostBridge = "brCont";
      config = {config, lib, pkgs, ...}: {
        imports = [
          containerConfig.config
        ];
        networking = {
          useHostResolvConf = lib.mkForce false;
          defaultGateway = "10.200.0.1";
          firewall.allowedTCPPorts = tcpPorts;
          firewall.allowedUDPPorts = tcpPorts;
        };
        services.resolved.enable = true;
        system.stateVersion = "23.11";
      };
    };
  };
}
