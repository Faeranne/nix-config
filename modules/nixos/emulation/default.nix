{...}: {
  programs.virt-manager.enable = true;
  virtualisation = {
    /*virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
      enableHardening = true;
    };*/
    libvirtd.enable = true;
  };
}
