self: {
  globalConfig = {
    modules ? [],
    specialArgs ? {},
    ...
  }: import ./global {
    inherit self modules specialArgs;
  };
  nixosModules = {
    default = {
      lib,
      ...
    }:let
      inherit (lib) mkEnableOption;
    in {
      options = {
        nexos = {
          enable = mkEnableOption "Enable all NexOS defaults and features.";
        };
      };

      imports = [
        ./hardware
      ];
    };
  };
}
