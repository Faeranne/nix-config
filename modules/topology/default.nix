{config, ...}: let 
  inherit (config.lib.topology) 
  mkInternet
  mkConnection
  mkRouter
  mkSwitch
  ;
in {
  nodes = {
    internet = mkInternet {
      connections = mkConnection "router" "wan2";
    };
    switch1 = mkSwitch "Rack PoE Switch" {
      interfaceGroups = [
        ["eth1" "eth3" "eth5" "eth7" "eth9" "eth11" "eth13" "eth15"]
        ["eth2" "eth4" "eth6" "eth8" "eth10" "eth12" "eth14" "eth16"]
        ["sfp1" "sfp2"]
      ];
      connections.sfp2 = mkConnection "router" "sfp1";
      interfaces.sfp2 = {
        addresses = ["192.168.1.90"];
        network = "home";
      };
    };
    switch2 = mkSwitch "Bedroom Switch" {
      interfaceGroups = [
        ["eth1" "eth2" "eth3" "eth4" "eth5" "eth6" "eth7" "eth8"]
      ];
      connections.eth1 = mkConnection "switch1" "eth2";
      interfaces.eth1 = {
        addresses = ["192.168.1.178"];
        network = "home";
      };
    };
    router = mkRouter "Unifi USG Pro 4" {
      interfaceGroups = [
        ["eth1" "eth2" "sfp1" "sfp2"]
        ["wan1" "wan2"]
      ];
      interfaces.sfp1 = {
        addresses = ["192.168.1.1"];
        network = "home";
      };
    };
  };
  networks.home = {
    name = "Home Network";
    cidrv4 = "192.168.1.1/24";
  };
}
