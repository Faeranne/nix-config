{systemConfig, ...}: {
  boot.binfmt.emulatedSystems = if systemConfig ? "emulate" then systemConfig.emulate else [];
  virtualization.libvirtd.enable = (systemConfig ? "emulate");
  programs.virtmanager.enable = (systemConfig ? "emulate");
}
