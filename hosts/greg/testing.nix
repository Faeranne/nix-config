{config, lib, ...}:{
  virtualisation.vmVariant = {
    virtualisation = {
      sharedDirectories = {
        "storage" = {
          target = "/Storage";
          source = "/tmp/vmManagement/storage";
          securityModel = "mapped-xattr";
        };
      };
    };
  };
}
