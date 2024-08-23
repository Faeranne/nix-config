{config, self, ...}: {
  age.secrets = {
    "wghub" = {
      rekeyFile = self + "/secrets/containers/${config.networking.hostName}/wireguard-hub.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
    "wggateway" = {
      rekeyFile = self + "/secrets/containers/${config.networking.hostName}/wireguard-gateway.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
  };
  systemd.services."wireguard-wghub" = {
    bindsTo = ["netns@container.service"];
    after = ["netns@container.service"];
  };

  networking = {
    firewall = {
      extraStopCommands = ''
        iptables -D FORWARD -i wggateway -o wggateway -j REJECT --reject-with icmp-adm-prohibited
      '';
      extraCommands = ''
        iptables -I FORWARD -i wggateway -o wggateway -j REJECT --reject-with icmp-adm-prohibited
      '';
    };

    wireguard.interfaces = {

      # Is used to join container wireguards between hosts
      "wghub" = {
        privateKeyFile = config.age.secrets."wghub".path;
        socketNamespace = "init";
        interfaceNamespace = "container";
      };

      # Allows local container wireguards to access the internet
      "wggateway" = {
        privateKeyFile = config.age.secrets."wggateway".path;
        listenPort = 51820;
        socketNamespace = "container";
        interfaceNamespace = "init";
      };
    };

    nat = {
      enable = true;
      internalInterfaces = [ "wggateway" ];
    };
  };
}
