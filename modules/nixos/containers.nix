{pkgs, systemConfig, lib, ...}: let
  containersEnabled = (builtins.elem "containers" systemConfig.elements);
in {
  age.generators.wireguard = {pkgs, file, ...}: ''
    priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
    ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
    echo "$priv"
  '';
  networking = {
    bridges = {
      brCont.interfaces = [];
      brIso.interfaces = [];
    };
    interfaces = {
      brCont.ipv4.addresses = [{
        address = "10.200.0.1";
        prefixLength = 16;
      }];
      brIso.ipv4.addresses = [{
        address = "10.210.0.1";
        prefixLength = 16;
      }];
    };

    firewall = {
      trustedInterfaces = [ "podman+" "brCont" "brIso" ];
    };

    nat = lib.mkIf containersEnabled {
      externalInterface = systemConfig.netdev;
      enable = true;
      internalInterfaces = [ "podman+" "ve-+" "vb-+" "brCont" ];
    };
  };
}
