{
  uid = 1000;
  authorizedKeys = [
    #"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/cW2SJ8afcTja9zxJ6mUDEguH6K/AI7vrvE5TTvCqVNx6ds1DpLjWaR3LtKSKOeD3JbxhvRMtAwDXBsY/JP25Y84dlsDdCFBMj8R9JwzgO6XVWEPLS7WPY7HeeVwC/FnAkH+qTsQPY8ftgK3ylX6UC7/Fheyh+OMPxS+Qrr/0c7DBjMOPYitUGCCiJHJZfTJT7i3nbnwZU06S9M1aqdMQyfznHJSaU+RNFqyt8yuUAxaulWHEofpxTFjCpY7VN59ECDcJeqCiGTE2PaHzNJUJIhFkRAkrM5DEVomHM9AdkAvKQ3sQa6SvZ2uw3EowmAbxpHjwmqGuW+vsvPdr/KL nina@fiona"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMg89gg80Z24JNaj1qeuEk4zxfA2AabKcuo6JHjSHu3xAAAAC3NzaDpwcml2YXRl nina@desktop"
  ];
  name = "Nina";
  shell = pkgs: pkgs.zsh;
  avatar = ./resources/avatar.png;
  wallpaper = ./resources/background.png;
  passwordPath = ./password.age;
}
