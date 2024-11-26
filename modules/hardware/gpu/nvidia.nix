{...}: let
in {
  #boot.initrd.kernelModules = [ "nvidia" ];
  services.xserver.videoDrivers = ["nvidia"];
  environment.systemPackages = with pkgs; [
    cudatoolkit
  ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };
}
