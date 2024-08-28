{config, lib, ...}:{
  virtualisation.vmVariant = {
    virtualisation = {
      graphics = true;
      sharedDirectories = {
        "storage" = {
          target = "/Storage";
          source = "/tmp/vmManagement/storage";
          securityModel = "mapped-xattr";
        };
      };
      diskImage = null;
    };
  };
  virtualisation.vmVariantWithBootLoader = config.virtualisation.vmVariant;
}
