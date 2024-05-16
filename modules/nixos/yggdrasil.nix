{config, systemConfig, lib, ...}: let

in {
  age.generators.yggdrasilKeyConf = {pkgs, file, ...}: ''
    pkey=$(${pkgs.openssl}/bin/openssl genpkey -algorithm ed25519 -outform pem | ${pkgs.openssl}/bin/openssl pkey -inform pem -text -noout)
    priv=$(echo "$pkey" | sed '3,5p;d' | tr -d "\n :")
    pub=$(echo "$pkey" | sed '7,10p;d' | tr -d "\n :")
    privConf="{\"PrivateKey\":\"$priv$pub\"}"
    ${pkgs.yggdrasil}/bin/yggdrasil -useconf -address <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".ip")}
    ${pkgs.yggdrasil}/bin/yggdrasil -useconf -publickey <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
    ${pkgs.yggdrasil}/bin/yggdrasil -useconf -subnet <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".net")}
    echo "$privConf"
  '';
  age.secrets.yggdrasil = {
    rekeyFile = ../../hosts/${systemConfig.hostname}/secrets/yggdrasil.age;
    generator = {
      script = "yggdrasilKeyConf";
      tags = ["yggdrasil"];
    };
  };
  services.yggdrasil = {
    enable = true;
    settings = {
    };
    openMulticastPort = true;
    group = "wheel";
    denyDhcpcdInterfaces = [ "tap" ];
    configFile = config.age.secrets.yggdrasil.path;
  };
  networking.firewall.allowedTCPPorts = [];
}
