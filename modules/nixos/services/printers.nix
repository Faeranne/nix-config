{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplipWithPlugin
    ];
  };
  environment.systemPackages = with pkgs; [
    hplipWithPlugin
  ];
}
