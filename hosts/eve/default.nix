{
  self,
  pkgs,
  ...
}: {
  imports = with self.nixosModules; [
    base
    extras.storage
    hardware.cpu.intel
    self.userModules.nina
  ];

  networking = {
    hostName = "eve";
    hostId = "586769c4";
    firewall = {
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  environment.systemPackages = [
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
