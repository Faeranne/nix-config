{ systemConfig , pkgs, lib, ...}: let
  isGnome = (builtins.elem "gnome" systemConfig.elements);
  isKde = (builtins.elem "kde" systemConfig.elements);
  isGraphical = isGnome || isKde;
  isLaptop = (builtins.elem "laptop" systemConfig.elements);
in {
  age.secrets.wifi-secrets.rekeyFile = ../../secrets/wifi.age
  networking.networkmanager.ensureProfiles = lib.mkIf isLaptop {
    profiles = {
      Nexus-Labs = {
        connection = {
          id = "Nexus-Lab";
          permissions = "";
          type = "wifi";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          method = "auto";
          addr-gen-mode = "default";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$NEXUSLABS_SSID";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$NEXUSLABS_PASSWORD";
        };
      };
    environmentFiles = [
      config.age.secrets.wifi-secrets.path
    ];
  };
}
