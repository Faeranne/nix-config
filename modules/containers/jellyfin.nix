{...}:let
  containerName = "jellyfin";
in {
  imports = [
    (import ./template.nix containerName)
  ];

  networking.wireguard.interfaces = {
    "wg${containerName}" = {
      ips = ["10.100.1.5/32"];
      peers = [
      ];
    };
  };

  containers.${containerName} = {
    bindMounts = {
      "/media" = {
        isReadOnly = false;
        create = true;
      };
      "/var/lib/jellyfin" = {
        isReadOnly = false;
        create = true;
      };
      "/config" = {
        isReadOnly = false;
        create = true;
      };
      "/dev/dri" = {
        hostPath = "/dev/dri";
        isReadOnly = false;
      };
      "/dev/shm" = {
        hostPath = "/dev/shm";
        isReadOnly = false;
      };
      "/dev/nvidia0" = {
        hostPath = "/dev/nvidia0";
        isReadOnly = false;
      };
      "/dev/nvidiactl" = {
        hostPath = "/dev/nvidiactl";
        isReadOnly = false;
      };
      "/dev/nvidia-modeset" = {
        hostPath = "/dev/nvidia-modeset";
        isReadOnly = false;
      }; "/dev/nvidia-uvm" = {
        hostPath = "/dev/nvidia-uvm";
        isReadOnly = false;
      };
      "/dev/nvidia-uvm-tools" = {
        hostPath = "/dev/nvidia-uvm-tools";
        isReadOnly = false;
      };
      "/dev/nvidia-caps" = {
        hostPath = "/dev/nvidia-caps";
        isReadOnly = false;
      };
    };

    allowedDevices = [
      {
        modifier = "rw";
        node = "/dev/dri";
      }
      {
        modifier = "rw";
        node = "/dev/dri/renderD128";
      }
      {
        modifier = "rw";
        node = "/dev/shm";
      }
      {
        modifier = "rw";
        node = "/dev/nvidiactl";
      }
      {
        modifier = "rw";
        node = "/dev/nvidia0";
      }
      {
        modifier = "rw";
        node = "/dev/nvidia-modeset";
      }
      {
        modifier = "rw";
        node = "/dev/nvidia-uvm-tools";
      }
      {
        modifier = "rw";
        node = "/dev/nvidia-uvm";
      }
      {
        modifier = "rw";
        node = "/dev/nvidia-caps";
      }
    ];
    specialArgs = {
      port = 8096;
    };

    config = {pkgs, port, ...}: {
      imports = [
        ./base.nix
      ];

      networking = {
        firewall = {
          allowedTCPPorts = [ port ];
        };
      };

      nixpkgs.config.allowUnfree = true;

      services = {
        xserver.videoDrivers = [ "nvidia" ];
        jellyfin.enable = true;
      };

      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          libvdpau-va-gl
          intel-media-driver
          intel-vaapi-driver # previously vaapiIntel
          vaapiVdpau
          intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
        ];
      };

      environment.systemPackages = with pkgs; [
        cudatoolkit
        jellyfin
        jellyfin-web
        jellyfin-ffmpeg
        id3v2
        yt-dlp
      ];

    };
  };
}
