{self, ...}:{
  imports = [
    self.containerModules.grocy
  ];
  containers = {
    grocy = {
      localAddress = "10.200.0.3";
      bindMounts = {
        "/var/lib/grocy" = {
          hostPath = "/persist/container/grocy";
        };
      };
      specialArgs = {
        hostName = "grocy.faeranne.com";
      };
    };
  };
  networking.wireguard.interfaces = {
    wggrocy = {
      listenPort = 51821;
      peers = [
        {
          name = "sarah";
          endpoint = "127.0.0.1:${toString self.nixosConfigurations.sarah.config.networking.wireguard.interfaces.wgsarah.listenPort}";
          publicKey = builtins.readFile (self + "/secrets/sarah/wireguard.pub");
          allowedIPs = self.nixosConfigurations.sarah.config.networking.wireguard.interfaces.wgsarah.ips;
        }
      ];
    };
  };
}
