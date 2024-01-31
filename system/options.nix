{lib, ...}: {
  options.custom.elements = lib.mkOption {
    default = [];
    description = "Whether to enable the default disk layout";
    type = lib.types.listOf lib.types.str;
  };
}
