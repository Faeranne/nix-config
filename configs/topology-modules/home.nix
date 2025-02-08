{
  config,
  ...
}: let
  inherit (config.lib.topology) mkRouter mkConnection mkSwitch;
in {
  networks.home = {
    name = "Home Network";
    cidrv4 = "192.168.1.1/24";
    publicIP = "68.58.53.23";
  };
  nodes = {
    rack_poe = mkSwitch "Rack PoE Switch" {
      info = "Unifi US 16 150W";
      interfaceGroups = [
        ["eth1" "eth3" "eth5" "eth7" "eth9" "eth11" "eth13" "eth15"]
        ["eth2" "eth4" "eth6" "eth8" "eth10" "eth12" "eth14" "eth16"]
        ["sfp1" "sfp2"]
      ];
      connections = {
        sfp2 = mkConnection "router" "sfp1";
      };
      interfaces.sfp2 = {
        addresses = ["192.168.1.90"];
        network = "home";
      };
    };
    livingroom = mkSwitch "Livingroom Switch" {
      info = "Unifi US 8";
      interfaceGroups = [
        ["eth1" "eth2" "eth3" "eth4"]
        ["eth5" "eth6" "eth7" "eth8"]
      ];
      connections = {
        eth1 = mkConnection "rack_poe" "eth10";
      };
      interfaces.eth1 = {
        addresses = ["192.168.1.108/24"];
        network = "home";
      };
    };
    bedroom = mkSwitch "Bedroom Switch" {
      info = "Unifi US 8 60W";
      interfaceGroups = [
        ["eth1" "eth2" "eth3" "eth4"]
        ["eth5" "eth6" "eth7" "eth8"]
      ];
      connections = {
        eth1 = mkConnection "rack_poe" "eth2";
      };
      interfaces.eth1 = {
        addresses = ["192.168.1.178/24"];
        network = "home";
      };
    };
    ap = {
      deviceType = "device";
      icon = "interfaces.wifi";
      interfaces = {
        eth1 = {
          addresses = [
            "192.168.1.117/24"
          ];
          network = "home";
          physicalConnections = [
            (mkConnection "rack_poe" "eth4")
          ];
        };
      };
    };
    router = mkRouter "Unifi USG Pro 4" {
      info = "USG-Pro-4";
      interfaceGroups = [
        ["eth1" "eth2" "sfp1" "sfp2"]
        ["wan1" "wan2"]
      ];
      connections = {
        wan2 = mkConnection "internet" "*";
      };
      interfaces = {
        wan2 = {
          addresses = ["68.54.222.18"];
        };
        sfp1 = {
          addresses = [ "192.168.1.1" ];
          network = "home";
        };
      };
    };
  };
}
