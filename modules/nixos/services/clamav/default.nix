{config, pkgs, ...}:{
  /*
  environment = {
    persistence."/persist" = {
      directories = [
        "/var/lib/clamav"
      ];
    };
    etc = {
      "clamav/clamd.conf" = {
        source = ./clamd.conf;
        user = "clamav";
        group = "clamav";
        mode = "0444";
      };
      "clamav/freshclam.conf" = {
        source = ./freshclam.conf;
        user = "clamav";
        group = "clamav";
        mode = "0440";
      };
    };
    systemPackages = [
      pkgs.clamav
    ];
  };

  systemd.services = {
    clamd = {
      description = "ClamAV Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.clamav}/bin/clamd --foreground=yes";
        Restart = "on-failure";
        User = "clamav";
        Group = "clamav";
        PrivateTmp = true;
        RuntimeDirectory = "clamav";
        RuntimeDirectoryMode = "0755";
        LogsDirectory = "clamav";
        LogsDirectoryMode = "0755";
        StateDirectory = "clamav";
        StateDirectoryMode = "0755";
      };
    };
    
    freshclam = {
      description = "ClamAV Virus Database Updater";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.clamav}/bin/freshclam --foreground=yes";
        Restart = "on-failure";
        User = "clamav";
        Group = "clamav";
        PrivateTmp = true;
        RuntimeDirectory = "clamav";
        RuntimeDirectoryMode = "0755";
        LogsDirectory = "clamav";
        LogsDirectoryMode = "0755";
        StateDirectory = "clamav";
        StateDirectoryMode = "0755";
      };
    };
  };

  users = {
    users.clamav = {
      isSystemUser = true;
      group = "clamav";
    };
    groups.clamav = {
    };
  };
  */
  services.clamav = {
    #scanner.enable = true;
    updater.enable = true;
    daemon.enable = true;
    #fangfrisch.enable = true;
  };
}
