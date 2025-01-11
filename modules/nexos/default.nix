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
      inherit (lib) mkOption mkEnableOption;
      inherit (lib.types) attrs;
    in {
      options = {
        nexos = {
          enable = mkEnableOption "Enable all NexOS defaults and features.";
          lib = mkOption {
            type = attrs;
            default = import ./lib.nix lib;
          };
          global = mkOption {
            description = "Global option entrypoint";
            type = attrs;
            default = {enable = false;};
          };
        };
      };

      imports = [
        ./hardware
        ./info
        ./users
        ./networking.nix
        ./nixconfig.nix
        ./secrets.nix
        ./storage.nix
        ./testing.nix
      ];
    };
  };
}
