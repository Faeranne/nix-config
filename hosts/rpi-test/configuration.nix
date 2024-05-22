{inputs, ...}:{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/netboot/netboot.nix"
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
