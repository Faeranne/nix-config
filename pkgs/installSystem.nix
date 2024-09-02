{pkgs}: let
  writePython3 = pkgs.writers.makePythonWriter pkgs.python312 pkgs.python312 pkgs.buildPackages.python312Packages;
  writePython3Bin = name: writePython3 "/bin/${name}";
in 
  writePython3Bin "install_system" {
    flakeIgnore = [ "E111" "E121" "E501" ];
    libraries = with pkgs.python312Packages; [ 
      diskinfo 
      pythondialog
      pyparted
      requests
      netifaces
    ];
    makeWrapperArgs = [
      "--prefix" "PATH" ":" "${pkgs.lib.makeBinPath [ pkgs.dialog ]}"
    ];
  } ./installSystem.py
