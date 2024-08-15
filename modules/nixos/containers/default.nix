{pkgs, lib, ...}: {
  age.generators.wireguard = {pkgs, file, ...}: ''
    priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
    ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
    echo "$priv"
  '';
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
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = false;
      ExecStart = "${pkgs.writers.writeDash "netns-up" ''
        ${pkgs.iproute}/bin/ip netns add $1
      ''} %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };
}
