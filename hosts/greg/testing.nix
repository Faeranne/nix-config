{nixosModules, ...}:{
  imports = [
    (nixosModules + "/virtualization/qemu-vm.nix")
  ];
}
