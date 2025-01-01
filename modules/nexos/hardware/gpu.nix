{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) submodule;
  cfg = config.nexos.hardware;
in {

  options = {
    nexos = {
      hardware = mkOption {
        type = submodule {
          options = {
            gpu = {
              nvidia = {
                enable = mkEnableOption "Enable Nvidia GPU config";
              };
              amd = {
                enable = mkEnableOption "Enable Amd GPU config";
              };
            };
          };
        };
      };
    };
  };

  config = (mkIf cfg.gpu.amd.enable {
    # AMD GPU config

    boot.initrd.kernelModules = ["amdgpu"];
    services.xserver.videoDrivers = ["amdgpu"];

    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  }) // (mkIf cfg.gpu.nvidia.enable {
    # Nidia GPU config

    services.xserver.videoDrivers = ["nvidia"];

    environment.systemPackages = with pkgs; [
      cudatoolkit
    ];

    hardware = {
      nvidia = {
        open = false;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          libvdpau-va-gl
        ];
      };
    };
  });
}
