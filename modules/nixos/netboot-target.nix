{inputs, config, hostServer, systemConfig, lib, pkgs, ...}:{

  boot = {
    kernelParams = [
      "debug"
      "netconsole=+r6665@/eth0,6665@${hostServer.net.ip}/${hostServer.net.mac}"
      "boot.shell_on_fail"
    ];
    loader = {
      systemd-boot.enable = false;
      timeout = 10;
    };
    supportedFilesystems = [
      "nfs"
      "nfsv4"
      "overlay"
    ];
    initrd = {
      systemd = {
        enable = true;
        enableTpm2 = lib.mkForce false;

        network = {
          enable = lib.mkForce true;
          networks = {
            "10-eth" = {
              matchConfig.Name = "end0";
              networkConfig.DHCP = "yes";
            };
          };
          wait-online = {
            enable = true;
          };
        };
        initrdBin = [
          pkgs.nfs-utils
          (pkgs.runCommand "mountnfs-sbin" {} ''
            mkdir -p $out/sbin
            cp ${pkgs.nfs-utils}/bin/mount.nfs $out/sbin/.
          '')
        ];
        emergencyAccess = true;
      };
      network = {
        enable = true;
        flushBeforeStage2 = false;

      };
      kernelModules = [
        "nfs"
        "nfsv4"
        "overlay"
      ];
      availableKernelModules = [
        "dummy"
        "nfs"
        "nfsv4"
        "overlay"
      ];
      supportedFilesystems = [
        "nfs"
        "nfsv4"
        "overlay"
      ];
    };
    postBootCommands = ''
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
  };

  fileSystems = {
    "/nix/.ro-store" = {
      fsType = "nfs";
      device = "${hostServer.net.ip}:/nix/store";
      neededForBoot = true;
    };
    "/nix/.rw-store" = { 
      fsType = "tmpfs";
      options = [ "mode=0755" ];
      neededForBoot = true;
    };
    "/nix/store" = { 
      fsType = "overlay";
      device = "overlay";
      overlay = {
        lowerdir = [ "/nix/.ro-store" ];
        upperdir = "/nix/.rw-store/store";
        workdir = "/nix/.rw-store/work";
      };
      depends = [
        "/nix/.ro-store"
        "/nix/.rw-store/store"
        "/nix/.rw-store/work"
      ];
      neededForBoot = true;
    };
  };
}
