{config, pkgs, lib, self, ...}:{

  networking = {
    # I've switched to systemd-networkd, so this option
    # is mandatory.  This is mostly due to how I handle
    # wireguard
    useNetworkd = true;
    # This sets open ports on the firewall, allowing
    # another system to access these ports from outside
    # my computer.
    firewall = {
      #
      allowedTCPPorts = [ 22000 ];
      # for KDEConnect
      # TODO: move to desktop
      allowedTCPPortRanges = [ {from = 1714; to = 1764; } ];
      #
      allowedUDPPorts = [ 22000 21027 ];
      # also for KDEConnect
      # TODO: move to desktop
      allowedUDPPortRanges = [ {from = 1714; to = 1764; } ];
    };
  };

  systemd = {
    # Paired with networking.useNetworkd, this enables systemd-networkd
    # see above for why
    network.enable = true;
    # This creates a template systemd unit, which creates a network namespace
    # of the given name.  This is incredibly useful for doing all sorts
    # of network shenanagans, like splitting a wireguard interface between
    # the host and a container. check out modules/nixos/containters/default.nix
    # to see how it's used
    services."netns@" = {
      description = "%I network namespace";
      before = ["network.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writers.writeDash "netns-up" ''
          ${pkgs.iproute}/bin/ip netns add $1
          # the default loopback adapter doesn't set itself up
          # so this enables it
          ${pkgs.iproute}/bin/ip netns exec $1 ${pkgs.iproute}/bin/ip link set lo up
        ''} %I";
        ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
      };
    };
  };

  services = {
    # Yggdrasil is a cool mesh network service, but I dropped it for now
    # due to processor requirements and a lack of need rn.
    # These settings remain so I can later correctly set it up.
    # but for now, they do nothing.  This is fine since it adds nothing
    # to the system if enable is false, and adds negligable build time
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

  # see modules/nixos/base/security.nix for more details about this
  age = {
    generators = {
      # unused right now, but makes 3 additional files for use
      # with yggdrasil.
      # secret.ip - the final ipv6 address that this secret shows up as
      # secret.pub - the public key of this secret
      # secret.net - the subnet address that this secret responds to
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
      # Creates a wireguard private and public key pair.
      # secret.age - encrypted private key for this secret.
      # secret.pub - plaintext public key for this secret. used in wireguard peer configs
      wireguard = {pkgs, file, ...}: ''
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
    };
  };
}
