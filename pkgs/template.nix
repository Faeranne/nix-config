{pkgs, ...}:
  pkgs.writers.writePython3Bin "template_file" {
    libraries = [
    ];
  } ''
    import 
  ''

