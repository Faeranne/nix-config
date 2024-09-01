{pkgs}:
  pkgs.writers.writePython3Bin "install_system" {
    flakeIgnore = [ "E111" "E121" "E501" ];
    libraries = with pkgs.python3Packages; [ 
      diskinfo 
      pythondialog
    ];
  } ''
    from diskinfo import DiskInfo
    di = DiskInfo()
    disks = di.get_disk_list(sorting=True)
    for d in disks:
      if (not d.get_model() == "") and (not d.get_name().startswith("sr")):
        print(f'Name: {d.get_name()} Model: {d.get_model()} serial: {d.get_serial_number()} Path: {d.get_byid_path()[0]}')
  ''
