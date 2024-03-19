# returns all the public keys for a given user.
user: let
  userConfig = import ../users/${user}/config.nix;
  hosts = builtins.attrNames userConfig.ssh_keys.hosts;
  keys = builtins.foldl' (acc: name: let
    host = builtins.getAttr name userConfig.ssh_keys.hosts;
    keyNames = builtins.attrNames host;
    keyReturns = builtins.foldl' (acc2: keyName: let
      entry = (builtins.getAttr keyName host);
    in
      acc2 ++ [ entry.pub ]
    ) [] keyNames;
  in
    acc ++ keyReturns
  ) [] hosts;
in
keys
