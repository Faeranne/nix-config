{pkgs, pkgs-stable, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs.stable; [
      hplipWithPlugin
    ];
  };
  environment.systemPackages = with pkgs.stable; [
    hplipWithPlugin
  ];
}
