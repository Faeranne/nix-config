{config, self, ...}: {
  age.secrets = {
    "wghub" = {
      rekeyFile = self + "/secrets/containers/${config.networking.hostName}/wireguard.age";
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
    wireguard.interfaces = {
      "wghub" = {
        privateKeyFile = config.age.secrets."wghub".path;
        socketNamespace = "init";
        interfaceNamespace = "container";
      };
    };

    nat = {
      enable = true;
    };
  };
}
