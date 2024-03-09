{systemConfig, ...}: {
  boot.binfmt.emulatedSystems = if systemConfig ? "emulate" then systemConfig.emulate else [];
  virtualisation.libvirtd.enable = (systemConfig ? "emulate");
  programs.virt-manager.enable = (systemConfig ? "emulate");
}
