{pkgs, ...}: {
  #boot.initrd.kernelModules = [ "nvidia" ];
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
}
