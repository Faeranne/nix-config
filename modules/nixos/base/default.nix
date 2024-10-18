{self, inputs, config, pkgs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.ragenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.stylix.nixosModules.stylix
    inputs.nix-topology.nixosModules.default
    ./networking.nix
    ./nix-config.nix
    ./security.nix
    ./storage.nix
    ./styling.nix
    ./testing.nix
    ./users.nix
  ];

  # This injects additional stuff in the argument set for every module.
  # This is mostly used for myLib, but since you can't just grab nurpkgs
  # directly without sometimes causing recursion, we use nur-no-packages
  # here to clip out the nurpkgs, and make nix nice and happy
  _module.args = {
    nur-no-packages = import inputs.nur {
      nurpkgs = pkgs;
    };
    myLib = self.lib;
  };

  system = {
    # Sets a `nixos-version --json` field to the current git repo, which can help with debugging
    configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";

    # Since nixos.label is only really used when running a boot switch, which doesn't happen
    # normally in a dirty repo, I'm only including it.  Dirty just reminds me that I intentionally
    # escaped my normal methods
    nixos.label = if self ? rev then "git-rev:${builtins.substring 0 8 self.rev}" else "dirty";

    # This is primarily for handling stateful stuff that doesn't move correctly from version
    # to version. For example, one cannot simply upgrade Postgres, and NextCloud must be upgraded
    # sequentially, you can't skip major versions during the upgrade.
    # This value makes sure everything that is stateful in this space doesn't upgrade just because
    # nixpkgs upgraded.  I originally built these systems in january of 2024, so everything
    # started with 23.11.  If I feel like it, I might upgrade everything to fit 24.05, but not
    # right now.  If you are setting this system *FROM SCRATCH*, you can change this right away.
    # Otherwise, dig through the nixpkgs repo and look for *every* instance of stateVersion.
    # If nothing conflicts with your current setup (make sure, cause some stuff will do things
    # like add postgres without you noticing), you can upgrade this.
    stateVersion = "23.11"; # Did you read the comment?
  };

  # Just some default values used everywhere.  These are well described in other linux documents.
  # Mainly make sure your timeZone matches your actual timezone
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs = {

    # This allows programs packaged with unknown or propriatry libraries.  Things like Discord
    # Otherwise, nix will refuse to build these programs, and thus this install will refuse
    # to build
    config.allowUnfree = true;

    # This changes values in `pkgs`. Mostly used to add external packages (via NUR) or roll forward
    # or backward certain packages.
    overlays = [
      inputs.nur.overlay
      (final: prev: {
        # I like using the newest features of Kicad, and they tend to trickle down to stable a little
        # slowly
        #kicad = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.kicad; 
        # As of this commit, PrismLauncher doesn't work right with the stable version.  Some login
        # issues. Check this later and roll back when it makes sense
        prismlauncher = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.prismlauncher; 
        # Inkscape crashes on wayland when a tablet is connected. 
        # https://gitlab.com/inkscape/inkscape/-/issues/4649
        inkscape = prev.pkgs.symlinkJoin {
          name = "inkscape";
          paths = [ prev.inkscape ];
          buildInputs = [ prev.pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/inkscape \
              --unset WAYLAND_DISPLAY
          '';
        };
      })
    ];
  };

  boot = {
    # All of this is about making appimage programs launch natively.
    # I'll admit, I don't remember where i found this.
    # TODO: Get the details for this again to properly document it
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };

  programs = {
    # I like ZSH, and having it as a system level shell is nice
    zsh.enable = true;
  };

  # Some of the default programs I use that aren't explicitly configured
  environment = {
    systemPackages = ((with pkgs; 
      [
        appimagekit
        appimage-run
        p7zip
      ]) ++
      # This next block only makes sense on x86 systems
      (if (
        pkgs.system == "x86_64-linux"
      ) then (
        # There are different packages for headless and graphical
        # otherwise I would jsut set this in a desktop config.
        # xdg.portal is needed for wayland desktops, so I just
        # look for that.
        if config.xdg.portal.enable then [ 
          pkgs.wineWowPackages.waylandFull
          pkgs.lxqt.lxqt-policykit
        ] else [ 
          pkgs.wineWowPackages.stagingFull
        ]
      # Nix requires else blocks. since I don't want to do anything
      # on non-x86 systems, I just return an empty result
      ) else [])
    );
  };

  # This causes the system to create a swap file *in-ram* which
  # means we can compress it on the fly.  This typically can result
  # in an additional 1.5x to 2x ram availability, depending on what
  # exactly is being stored.
  zramSwap = {
    enable = true;
  };
}
