{pkgs}:
  pkgs.writers.writePython3Bin "generate_uuid" {
    flakeIgnore = [ "E111" "E121" ];
  } ''
    import os
    import sys
    import json
    part = [
      os.urandom(2).hex().upper(),
      os.urandom(2).hex().upper()
    ]
    hostid = os.urandom(4).hex().upper()
    hostName = sys.argv[1]
    with open(f'{hostName}.json', 'w') as f:
      json.dump({
        "hostname": hostName,
        "hostId": hostid,
        "partition": "-".join(part)
      }, f)
    with open(f'{hostName}.sh', 'w') as f:
      lines = [
        f'mkdosfs -i {"-".join(part)} $1'
      ]
      f.writelines(lines)
  ''
