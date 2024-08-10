{...}:{
  imports = [
    (import ./template.nix "jellyfin")
  ];

  containers.jellyfin = {
    bindMounts = {
      "/media" = {
        isReadOnly = false;
      };
      "/var/lib/jellyfin" = {
        isReadOnly = false;
      };
      "/config" = {
        isReadOnly = false;
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
      };
      "/dev/nvidia-uvm" = {
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

    config = {pkgs, ...}: {
      imports = [
        ./base.nix
      ];

      networking = {
        firewall = {
          allowedTCPPorts = [ 8096 ];
        };
      };

      nixpkgs.config.allowUnfree = true;

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

      services.jellyfin = {
        xserver.videoDrivers = [ "nvidia" ];
        enable = true;
      };
    };
  };
}
