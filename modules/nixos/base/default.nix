{self, inputs, lib, config, pkgs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-generators.nixosModules.all-formats
    inputs.home-manager.nixosModules.home-manager
    inputs.ragenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.stylix.nixosModules.stylix
    ./users.nix
  ];
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
      (final: prev: {
        kicad = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.kicad; 
      })
    ];
  };
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  networking = {
    useNetworkd = true;
    firewall = {
      allowedTCPPortRanges = [ {from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ {from = 1714; to = 1764; } ];
    };
  };

  systemd.network.enable = true;

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
    yggdrasil = {
      enable = true;
      settings = {
      };
      openMulticastPort = true;
      group = "wheel";
      denyDhcpcdInterfaces = [ "tap" ];
      configFile = config.age.secrets.yggdrasil.path;
    };
  };

  programs = {
    zsh.enable = true;
  };

  environment = {
    persistence."/persist" = {
      directories = [
        "/var/lib/tpm"
        "/var/logs"
        "/etc/nixos"
        "/home"
      ];
      hideMounts = true;
      files = [
        "/etc/machine-id"
      ];
    };
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
    generators = {
      wireguard = {pkgs, file, ...}: ''
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
      yggdrasilKeyConf = {pkgs, file, ...}: ''
        pkey=$(${pkgs.openssl}/bin/openssl genpkey -algorithm ed25519 -outform pem | ${pkgs.openssl}/bin/openssl pkey -inform pem -text -noout)
        priv=$(echo "$pkey" | sed '3,5p;d' | tr -d "\n :")
        pub=$(echo "$pkey" | sed '7,10p;d' | tr -d "\n :")
        privConf="{\"PrivateKey\":\"$priv$pub\"}"
        ${pkgs.yggdrasil}/bin/yggdrasil -useconf -address <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".ip")}
        ${pkgs.yggdrasil}/bin/yggdrasil -useconf -publickey <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        ${pkgs.yggdrasil}/bin/yggdrasil -useconf -subnet <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".net")}
        echo "$privConf"
      '';
    };
    secrets = {
      yggdrasil = {
        rekeyFile = self + "/hosts/${config.networking.hostName}/secrets/yggdrasil.age";
        generator = {
          script = "yggdrasilKeyConf";
          tags = ["yggdrasil"];
        };
      };
    };
  };

  stylix = {
    autoEnable = false;
    polarity = "dark";
    image = self + "/resources/background.png";
  };

}
