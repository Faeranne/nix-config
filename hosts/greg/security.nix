{self, ...}:{
  age.secrets = {
    "openvpn_pass" = {
      rekeyFile = self + "/secrets/containers/wireguard.age";
      group = "systemd-network";
      mode = "770";
    };
    "openvpn_user" = {
      rekeyFile = self + "/secrets/containers/wireguard.age";
      group = "systemd-network";
      mode = "770";
    };
    "mullvad_address" = {
      rekeyFile = self + "/hosts/greg/secrets/mullvad_address.age";
      group = "systemd-network";
      mode = "770";
    };
    "github_runner" = {
      rekeyFile = self + "/secrets/containers/wireguard.age";
      group = "systemd-network";
      mode = "770";
    };
    freshrss = {
      rekeyFile = self + "/secrets/containers/freshrss.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "passphrase";
        tags = [ "pregen" ];
      };
    };
    paperless_superuser = {
      rekeyFile = self + "/secrets/containers/wireguard.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "passphrase";
        tags = [ "pregen" ];
      };
    };
    mullvad = {
      rekeyFile = self + "/hosts/greg/secrets/mullvad.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "fixed" ];
      };
    };
    "wggreg" = {
      rekeyFile = self + "/secrets/greg/wireguard.age";
      group = "systemd-network";
      mode = "770";
      generator = {
        script = "wireguard";
        tags = [ "wireguard" ];
      };
    };
  };
}
