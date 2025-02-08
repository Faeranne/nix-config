{
  pkgs,
  ...
}:{
  boot.initrd.systemd.tpm2.enable = true;
  security = {
    tpm2 = {
      enable = true;
      tctiEnvironment.enable = true;
      pkcx11.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    tpm2-tools
    tpm-tools
    tpmmanager
  ];
}
