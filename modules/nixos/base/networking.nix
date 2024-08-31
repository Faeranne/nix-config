{config, pkgs, lib, self, ...}:{
  networking = {
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedTCPPortRanges = [ {from = 1714; to = 1764; } ];
      allowedUDPPorts = [ 22000 21027 ];
      allowedUDPPortRanges = [ {from = 1714; to = 1764; } ];
    };
  };

  systemd = {
    network.enable = true;
    services."netns@" = {
      description = "%I network namespace";
      before = ["network.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writers.writeDash "netns-up" ''
          ${pkgs.iproute}/bin/ip netns add $1
          ${pkgs.iproute}/bin/ip exec $1 ${pkgs.iproute}/bin/ip link set lo up
        ''} %I";
        ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
      };
    };
  };

  services = {
    yggdrasil = {
      enable = false;
      settings = {
      };
      openMulticastPort = true;
      group = "wheel";
      denyDhcpcdInterfaces = [ "tap" ];
      configFile = config.age.secrets.yggdrasil.path;
    };
  };

  age = {
    generators = {
      yggdrasilKeyConf = {pkgs, file, ...}: ''
        pkey=$(${pkgs.openssl}/bin/openssl genpkey -algorithm ed25519 -outform pem | ${pkgs.openssl}/bin/openssl pkey -inform pem -text -noout)
        priv=$(echo "$pkey" | sed '3,5p;d' | tr -d "\n :")
        pub=$(echo "$pkey" | sed '7,10p;d' | tr -d "\n :")
        privConf="{\"PrivateKey\":\"$priv$pub\"}"
        ${pkgs.yggdrasil}/bin/yggdrasil -useconf -address <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".ip")}
        ${pkgs.yggdrasil}/bin/yggdrasil -useconf -publickey <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        ${pkgs.yggdrasil}/bin/yggdrasil -useconf -subnet <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".net")}
        echo "$privConf"
      '';
      wireguard = {pkgs, file, ...}: ''
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
    };
    secrets = {
      yggdrasil = {
        rekeyFile = self + "/hosts/${config.networking.hostName}/secrets/yggdrasil.age";
        generator = {
          script = "yggdrasilKeyConf";
          tags = ["yggdrasil"];
        };
      };
    };
  };
}
