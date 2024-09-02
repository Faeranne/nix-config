{pkgs}: let
  writePython3 = pkgs.writers.makePythonWriter pkgs.python312 pkgs.python312 pkgs.buildPackages.python312Packages;
  writePython3Bin = name: writePython3 "/bin/${name}";
in 
  writePython3Bin "gather_clues" {
    flakeIgnore = [ "E111" "E121" "E501" ];
    libraries = with pkgs.python312Packages; [ 
      pythondialog
      requests
    ];
    makeWrapperArgs = [
      "--prefix" "PATH" ":" "${pkgs.lib.makeBinPath (with pkgs; [ dialog age age-plugin-yubikey ])}"
    ];
  } ./gatherClues.py
