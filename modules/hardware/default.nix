{
  bluetooth = import ./bluetooth.nix;
  oracle = import ./oracle.nix;
  rpi = import ./rpi.nix;
  cpu = {
    amd = import ./cpu/amd.nix;
    intel = import ./cpu/intel.nix;
  };
  gpu = {
    amd = import ./gpu/amd.nix;
    nvidia = import ./gpu/nvidia.nix;
  };
}
