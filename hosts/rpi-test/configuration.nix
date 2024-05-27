{inputs, ...}:{
  imports = [
  ];
  boot = {
    loader = {
      systemd-boot.enable = false;
      grub.enable = false;
      #generic-extlinux-compatible.enable = false;
      external.enable = false;
    };
  };
}
