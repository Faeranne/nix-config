{
  age.generators = {
    wireguard = {
      pkgs,
      file,
      lib,
      ...
    }: ''
      priv=$(${lib.getExe pkgs.wireguard-tools} genkey)
      ${lib.getExe pkgs.wireguard-tools} pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
      echo "$priv"
    '';
  };
}
