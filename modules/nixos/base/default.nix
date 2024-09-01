{self, inputs, lib, config, pkgs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.ragenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.stylix.nixosModules.stylix
    inputs.nix-topology.nixosModules.default
    ./users.nix
    ./testing.nix
    ./storage.nix
    ./networking.nix
  ];

  _module.args = {
    nur-no-packages = import inputs.nur {
      nurpkgs = pkgs;
    };
    myLib = self.lib;
  };

  system = {
    configurationRevision = if self ? rev then self.rev else if self ? dirtyRev then self.dirtyRev else "dirty";
    stateVersion = "23.11"; # Did you read the comment?
    # Since nixos.label is only really used when running a boot switch, which doesn't happen
    # normally in a dirty repo, I'm only including it.  Dirty just reminds me that I intentionally
    # escaped my normal methods
    nixos.label = if self ? rev then "git-rev:${builtins.substring 0 8 self.rev}" else "dirty";
  };
  # Base elements

  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlay
      (final: prev: {
        kicad = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.kicad; 
        prismlauncher = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.prismlauncher; 
      })

    ];
  };
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" "ca-derivations"];
    };
    extraOptions = ''
      !include ${config.age.secrets.flake-accessTokens.path};
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  boot = {
    supportedFilesystems = [
      "vfat"
      "zfs"
    ];
    initrd.systemd.enableTpm2 = true;
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };

  services = {
    pcscd.enable = true;
    tcsd.enable = true;
    zfs = {
      autoScrub = {
        enable = true;
      };
    };
  };

  programs = {
    zsh.enable = true;
  };

  environment = {
    systemPackages = with pkgs; (
      [
        appimagekit
        appimage-run
        tpm2-tools
        tpm-tools
        tpmmanager
        p7zip
        yubikey-manager
      ] ++
      (if (
        pkgs.system == "x86_64-linux"
      ) then (
        if config.xdg.portal.enable then [ 
          wineWowPackages.waylandFull
          lxqt.lxqt-policykit
        ] else [ 
          wineWowPackages.stagingFull
        ]
      ) else [])
    );
  };

  zramSwap = {
    enable = true;
  };

  security = {
    tpm2 = {
      enable = true;
      tctiEnvironment.enable = true;
      pkcs11.enable = true;
    };
    polkit = {
      enable = true;
    };
    pam = { 
      services = {
        swaylock = {};
      };
      sshAgentAuth = {
        enable = true;
      };
    };
  };

  age = {
    identityPaths = [ "/persist/agenix.key" "/nix/agenix.key" ];
    rekey = {
      storageMode = "local";
      localStorageDir = self + "/secrets/rekeyed/${config.networking.hostName}";
      agePlugins = [ pkgs.age-plugin-yubikey ];
      generatedSecretsDir = self + "/secrets/generated";
      masterIdentities = [ "/tmp/yubikey.pub" ];
      extraEncryptionPubkeys = [ 
        "age1yubikey1qtfy343ld8e5sxlvfufa4hh22pm33f6sjq2usx6mmydrmu7txzu7g5xm9vr"
        "age1yubikey1qdnfvhjlw8j2dkksj9eyxaqwldtqw4427cqjjqxulr5t7gn4flnt25lhuyw"
        "age1yubikey1qw43gcah5lr95c4klyavduax0drqd5a95lhs8u2wpzqrtcklw5f0uwruyek"
        "age1yubikey1qwcdxfaalqhntrsrkt7p2nyngdyjc72jr8tehgdzgwwpsl0veflrxncut3x"
      ];
    };
    secrets = {
      flake-accessTokens = {
        rekeyFile = self + "/secrets/accessTokens.age";
        mode = "770";
        group = "nixbld";
      };
    };
  };

  stylix = {
    autoEnable = false;
    polarity = "dark";
    image = self + "/resources/background.png";
    base16Scheme = {
      base00 = "000000";
      base01 = "242424";
      base02 = "008f00";
      base03 = "929292";
      base04 = "7f3300";
      base05 = "b44800";
      base06 = "ff6700";
      base07 = "474747";
      base08 = "ff0000";
      base09 = "ff4300";
      base0A = "b1a100";
      base0B = "5aff00";
      base0C = "00acb1";
      base0D = "50d8dc";
      base0E = "008fff";
      base0F = "5d1bb0";
    };
    targets = {
      plymouth = {
        enable = true;
        logo = self + "/resources/labs-color-nix-snowflake.png";
      };
      nixos-icons.enable = true;
      console.enable = true;
    };
  };

}
