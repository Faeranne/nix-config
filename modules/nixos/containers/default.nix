{pkgs, lib, ...}: {
  networking = {
    bridges = {
      brCont.interfaces = [];
    };
    interfaces = {
      brCont.ipv4.addresses = [{
        address = "10.200.0.1";
        prefixLength = 16;
      }];
    };

    firewall = {
      trustedInterfaces = [ "podman+" "brCont" ];
    };

    nat = {
      enable = true;
      internalInterfaces = [ "podman+" "ve-+" "vb-+" "brCont" ];
    };
  };
}
