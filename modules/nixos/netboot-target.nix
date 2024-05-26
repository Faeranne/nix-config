{inputs, config, hostServer, systemConfig, lib, pkgs, ...}:{

  boot = {
    kernelParams = [
      "debug"
      "netconsole=+r6665@/eth0,6665@${hostServer.net.ip}/${hostServer.net.mac}"
    ];
    loader = {
      timeout = 10;
    };
    initrd = {
      availableKernelModules = [ "nfs" "overlay" ];
      kernelModules = [ "overlay" ];
    };
  };

  fileSystems = {
    "/nix/.ro-store" = {
      fsType = "nfs";
      device = "${hostServer.ip}:/nix/store";
    };
    "/nix/.rw-store" = { 
      fsType = "tmpfs";
      options = [ "mode=0755" ];
      neededForBoot = true;
    };
    "/nix/store" = { 
      overlay = {
        lowerdir = [ "/nix/.ro-store" ];
        upperdir = "/nix/.rw-store/store";
        workdir = "/nix/.rw-store/work";
      };
      neededForBoot = true;
    };
  };

  boot.postBootCommands = ''
    # After booting, register the contents of the Nix store
    # in the Nix database in the tmpfs.
    ${config.nix.package}/bin/nix-store --load-db < /nix/store/nix-path-registration

    # nixos-rebuild also requires a "system" profile and an
    # /etc/NIXOS tag.
    # We don't enable these since all netboot systems are supposed to be stateless
    # and nixos-rebuild isn't used for them
    touch /etc/NIXOS
    ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
  '';

}
