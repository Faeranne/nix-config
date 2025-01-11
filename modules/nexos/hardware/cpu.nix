{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault mkOption mkEnableOption;
  inherit (lib.types) submodule;
  enable = config.nexos.enable;
  cfg = config.nexos.hardware;
in {
  options = {
    nexos = {
      hardware = mkOption {
        type = submodule {
          options = {
            efi = {
              enable = mkEnableOption "Enable EFI settings";
            };
            cpu = {
              intel = {
                enable = mkEnableOption "Enable Intel CPU config";
                enableGpu = mkEnableOption "Enable Intel integrated graphics";
              };
              amd = {
                enable = mkEnableOption "Enable Amd CPU config";
              };
            };
          };
        };
      };
    };
  };
  config = mkIf enable (mkMerge [
    {
      boot = {
        initrd = {
          availableKernelModules = ["nvme" "usbhid" "usb_storage" "sd_mod"];
        };
      };
    }
    (mkIf cfg.efi.enable {
      # EFI config

      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    })
    (mkIf cfg.cpu.intel.enable {
      # Intel config

      nixpkgs = {
        hostPlatform = mkDefault "x86_64-linux";
      };

      boot = {
        initrd = {
          availableKernelModules = ["xhci_pci" "ehci_pci" "ahci"];
        };
        kernelModules = ["kvm-intel"];
      };

      hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    })
    (mkIf cfg.cpu.intel.enableGpu {
      # Intel GPU config

      nixpkgs = {
        config.packageOverrides = (pkgs: {
          vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
        });
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
          vaapiVdpau
          libvdpau-va-gl
          intel-compute-runtime
        ];
      };
    })
    (mkIf cfg.cpu.amd.enable {
      # AMD config

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot = {
        kernelModules = ["kvm-amd"];
        initrd.availableKernelModules = ["xhci_pci" "ahci"];
      };

      hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    })
  ]);
}
