{config, lib, ...}:{
  system.activationScripts = {
    agenixNewGeneration.text = lib.mkVMOverride "";
    agenixInstall.text = lib.mkVMOverride ''
      ln -sfT /agenix /run/agenix
    '';
    agenixChown.text = lib.mkVMOverride "";
  };
  virtualisation.vmVariant = {
    virtualisation = {
      graphics = false;
      sharedDirectories = {
        "agenix" = {
          target = "/agenix";
          source = "/tmp/vmManagement/secretManagement/run/agenix";
          securityModel = "passthrough";
        };
        "persist" = {
          target = "/persist";
          source = "/tmp/vmManagement/persist";
          securityModel = "mapped-xattr";
        };
      };
      diskImage = null;
    };
  };
  virtualisation.vmVariantWithBootLoader = config.virtualisation.vmVariant;
}
