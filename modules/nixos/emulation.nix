{systemConfig, ...}: let
  isVirtualize = (builtins.elem "virtualization" systemConfig.elements);
in{
  boot.binfmt.emulatedSystems = if systemConfig ? "emulate" then systemConfig.emulate else [];
  virtualisation.libvirtd.enable = (systemConfig ? "emulate");
  programs.virt-manager.enable = (systemConfig ? "emulate");
  virtualisation.virtualbox.host = {
    enable = isVirtualize;
    enableExtensionPack = true;
    enableHardening = true;
  };
}
