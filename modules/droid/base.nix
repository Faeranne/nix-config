{...}:{
  environment.etcBackupExtension = ".bak";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "America/Indiana/Indianapolis";
}
