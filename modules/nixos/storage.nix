/*
  OK, this file does a lot with not a lot of info.
  Basically, we're generating a disko script *and* all the `filesystem`
  configs at the same time. This makes re-deploying systems fairly
  easy.

  A few things of note here, anything reliant here (so impermanence and
  lowmem) *cant be changed* after a system is deployed.  This is because
  the entire disk system is set during install, and won't match up if these
  values are changed after the fact.
  This is primarily because we use an actual zfs dataset for / if lowmem
  is set, rather than a tmpfs system.
*/
{systemConfig, lib, ...}: let
  isImpermanent = (builtins.elem "impermanence" systemConfig.elements);
  isLowMem = (builtins.elem "lowmem" systemConfig.elements);
  isNetboot = (builtins.elem "netboot" systemConfig.elements);
in{

  #If we have a `zfs` option in systemConfig, we load those pools at boot.
  boot.zfs.extraPools = if systemConfig.storage ? "zfs" then systemConfig.storage.zfs else [];
  boot.supportedFilesystems = [ "zfs" ];

  #there's a minor cpu tradeoff when we use zramSwap (is minimal, but
  #because I'm pedantic, I want control over it.
  zramSwap = {
    enable = isLowMem;
  };

  environment = lib.mkIf isImpermanent {
    persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/logs"
        "/etc/nixos"
        "/home"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  services = {
    zfs = {
      autoScrub = {
        enable = true;
        pools = [
          "zroot"
        ];
      };
    };
  };

  disko = {
    devices = {
      #If we use impermanence and are *not* memory constrained
      #We make / a tmpfs as mentioned above.  This enforces
      #impermanence.  Anything not in /nix or /persist (or /boot,
      #but that's not really a valid place to save stuff for reasons) 
      #*will* be lost on reboot, and that's intentional. 
      #see https://grahamc.com/blog/erase-your-darlings/
      #for more info on why this is a good thing.
      #I use tmpfs since / is gonna (hopefully) be 99% symlinks
      #and thus should be very smol.
      nodev = lib.mkIf (isImpermanent && !isLowMem) {
        "/" = {
          fsType = "tmpfs";
          #Gotta set mode or things won't be executable or readable by
          #non-root users.
          mountOptions = [
            "mode=755"
          ];
        };
      };
      disk = {
        #We only ever define 1 disk in this config.  anything additional
        #needs to be set in the host-specific configuration.nix
        #since we can only ever assume 1 attached storage device (note
        #that with netbooting, this will not even be true, so this will
        #change in the future.
        disk1 = {
          device = systemConfig.storage.root;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = lib.mkIf (!isNetboot) {
                name = "EFI";
                type = "EF00";
                start = "1M";
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              persist = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      zpool = {
        zroot = {
          type = "zpool";
          #Each of these defines a potential root layout
          #state.  Since there is no elseif option, we chain
          #if operations with // to merge the results down.
          datasets = (if isImpermanent then {
            #Persist always exists with impermanence, since /
            #*should* be fresh each boot.
            "persist" = {
              type = "zfs_fs";
              mountpoint = "/persist";
            };
          } else {
            #this space intentionally left blank, since the alternative
            #is handled in the next space.
          }) // (if isLowMem || !isImpermanent then {
            #Since lowmem assumes tmpfs doesn't have much room, we
            #treat it the same as having no impermanent flag.
            #The correct response here is to nuke / on boot when we *are* impermanent
            #, but I'm lazy, so I haven't set that up yet.
            "root" = {
              type = "zfs_fs";
              mountpoint = "/";
            };
          } else {
            #Since not lowmem is either gonna also be not impermanent or handled above,
            #once again we have an empty space.  What I would give for elseif.
          }) // (if (isNetboot) then {
            #If we're netbooting, we don't want to create the nixstore locally.
          } else {
            #Unless we're netbooting, we gotta have a nix store somewhere, so here's where it ends up.
            "nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
            };
          });
        };
      };
    };
  };

  #This marks a few datasets as required for boot, since the zfs config doesn't do that.
  #Otherwise neither of these will actually be setup before leaving stage1 boot,
  #which means we won't have any persistant config files *or* a nix store.  Can't
  #work with nothing.
  fileSystems = {
    #Since we won't have a /persist if we aren't impermanent, we use mkIf to effectively make this just equal to {}
    #if the system isn't impermanet. (Note that nixos modules do a lot more to actually hide this value, but
    #it's not actually possible to set a value to nothing in nix, so this is kinda what it ends up looking like)
    "/persist" = lib.mkIf isImpermanent {neededForBoot = true;};
    "/nix" = {
      neededForBoot = true;
    };
  };
}
