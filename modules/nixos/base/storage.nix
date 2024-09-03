{config, lib, ...}:{
  options = {
    environment = {
      # This defines an `environment.createDir` option
      # in nixos. Any config module can now define
      # this array like the example below, and the
      # system will create those on activation.
      # see the `system.activationScripts` section at
      # the bottom for details
      createDir = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              description = "Path to create";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root:root";
              description = ''
                `user:group` pair to
                create the directory with
              '';
            };
            permissions = lib.mkOption {
              type = lib.types.str;
              default = "755";
              description = ''
                permissions in octa format
                to assign the directory on creation
              '';
            };
          };
        });
        default = [];
        description = ''
          A list of submodules containing
          directories to create on activation.
        '';
      };
    };
  };
  config = let
    cfg = config.environment.createDir;
  in {
    environment = {
      # These are all paths that contain mandatory state.
      # Everything here is symlinked from a matching
      # directory in `/persist` during boot
      # Check out the Impermanence project for more
      # details.
      persistence."/persist" = {
        directories = [
          "/var/lib/tpm"
          "/var/logs"
          "/etc/nixos"
        ];
        # This prevents these from showing up in graphical
        # file managers
        hideMounts = true;
        # Same as above, but for files.  I forget why
        # it needs to be seperate, but it is.
        files = [
          "/etc/machine-id"
        ];
      };
    };

    programs = {
      # This allows fuse mounts to be accessed by other users
      # Primarily this makes it so sudo access inside
      # persisted user directories works.
      # Yes, that means that even root can't access this stuff
      # normally without massive work arounds.  Crazy
      fuse.userAllowOther = true;
    };

    services = {
      zfs = {
        # Runs `zpool scrub` regularly.  The pools scrubbed is
        # defined elsewhere, including in `modules/nixos/extras/storage.nix`
        # and the different host configs.
        # Zpool Scrub ensures all the data is consistant, that
        # no drives are experiencing major issues, and corrects
        # any bit flips or other random noise errors that can
        # crop up over time.
        autoScrub = {
          enable = true;
        };
      };
    };

    boot = {
      # by default the systems I use run vfat for the EFI partition
      # and zfs for everything else.  This ensures both filesystem
      # modules are loaded at boot. This mostly only affects the
      # initrd size, and generally is fine to keep around
      supportedFilesystems = [
        "vfat"
        "zfs"
      ];
    };

    system.activationScripts = let
      # This is a script that runs on *every* activation.  Activations
      # happen when `nixos-rebuild test` or `nixos-rebuild switch` is
      # run, as well as every single time the system boots.
      # 
      # This script handles creating useful directories ahead of time.
      # these are defined in `environments.createDir`.  See in the 
      # options field at the top for more info.
      allDirs = lib.foldl' (acc: value: acc + ''
        mkdir -p --mode="${value.permissions}" "${value.path}"
        chown "${value.owner}" "${value.path}"
      '') "" cfg;
    in {
      createDirectories = {
        text = allDirs;
        deps = [ "persist-files" ];
      };
    };
  };
}
