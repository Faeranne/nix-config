{self, pkgs}: let
  # If we're on a clean repo (everything is commited and no untracked files exist), then we
  # do the full nixos-rebuild, including setting up the boot requirements.
  # If it's still dirty, we just do a test, which will revert on reboot.
  action = if self ? rev then "switch" else "test";
  # I include a message to let myself know if things are being setup for boot or not.
  message = if self ? rev then "Clean repo, full switch" else "Dirty repo, only testing";
in pkgs.writeShellScriptBin "deploy" ''
  echo ${message}
  # nettools/hostname grabs the hostname of the current system. We do this here instead of in
  # the flake.nix because we can't introduce impurity at that stage.  Techinically it should always
  # be the same regardless, since we never push this script to any other system, but you never know,
  # and Nix really does care.
  sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake .#`${pkgs.nettools}/bin/hostname` ${action}
'';
