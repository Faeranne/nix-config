{ lib, pkgs, ... }: {
  users.extraUsers.nixos.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/cW2SJ8afcTja9zxJ6mUDEguH6K/AI7vrvE5TTvCqVNx6ds1DpLjWaR3LtKSKOeD3JbxhvRMtAwDXBsY/JP25Y84dlsDdCFBMj8R9JwzgO6XVWEPLS7WPY7HeeVwC/FnAkH+qTsQPY8ftgK3ylX6UC7/Fheyh+OMPxS+Qrr/0c7DBjMOPYitUGCCiJHJZfTJT7i3nbnwZU06S9M1aqdMQyfznHJSaU+RNFqyt8yuUAxaulWHEofpxTFjCpY7VN59ECDcJeqCiGTE2PaHzNJUJIhFkRAkrM5DEVomHM9AdkAvKQ3sQa6SvZ2uw3EowmAbxpHjwmqGuW+vsvPdr/KL nina@fiona"
  ];
  users.extraUsers.root.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/cW2SJ8afcTja9zxJ6mUDEguH6K/AI7vrvE5TTvCqVNx6ds1DpLjWaR3LtKSKOeD3JbxhvRMtAwDXBsY/JP25Y84dlsDdCFBMj8R9JwzgO6XVWEPLS7WPY7HeeVwC/FnAkH+qTsQPY8ftgK3ylX6UC7/Fheyh+OMPxS+Qrr/0c7DBjMOPYitUGCCiJHJZfTJT7i3nbnwZU06S9M1aqdMQyfznHJSaU+RNFqyt8yuUAxaulWHEofpxTFjCpY7VN59ECDcJeqCiGTE2PaHzNJUJIhFkRAkrM5DEVomHM9AdkAvKQ3sQa6SvZ2uw3EowmAbxpHjwmqGuW+vsvPdr/KL nina@fiona"
  ];
  nix.settings.trusted-users = [
    "nixos"
  ];
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  # Enable OpenSSH out of the box.
  services.sshd.enable = true;
  environment.systemPackages = with pkgs; [
    gitFull
    neovim
  ];
}
