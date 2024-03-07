{ config, pkgs, inputs, ... }:
let
  sops = inputs.sops;
  home-manager = inputs.home-manager;
in
{
  nix.settings.trusted-users = [ "nina" ];
  security.sudo.wheelNeedsPassword = false;
  sops.secrets.nina = {
    neededForUsers = true;
    sopsFile = ../secrets/users.yaml;
  };
  users.users.nina = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "docker" "audio" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = config.sops.secrets.nina.path;
    description = "Nina";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/cW2SJ8afcTja9zxJ6mUDEguH6K/AI7vrvE5TTvCqVNx6ds1DpLjWaR3LtKSKOeD3JbxhvRMtAwDXBsY/JP25Y84dlsDdCFBMj8R9JwzgO6XVWEPLS7WPY7HeeVwC/FnAkH+qTsQPY8ftgK3ylX6UC7/Fheyh+OMPxS+Qrr/0c7DBjMOPYitUGCCiJHJZfTJT7i3nbnwZU06S9M1aqdMQyfznHJSaU+RNFqyt8yuUAxaulWHEofpxTFjCpY7VN59ECDcJeqCiGTE2PaHzNJUJIhFkRAkrM5DEVomHM9AdkAvKQ3sQa6SvZ2uw3EowmAbxpHjwmqGuW+vsvPdr/KL nina@fiona"
    ];
    shell = pkgs.zsh;
  };
  users.users.services = {
    isNormalUser = false;
    group = "services";
    uid = 999;
  };
  users.groups.services = {};

}
