{self, inputs, lib, config, pkgs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-generators.nixosModules.all-formats
    inputs.home-manager.nixosModules.home-manager
    inputs.ragenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.stylix.nixosModules.stylix
    inputs.nix-topology.nixosModules.default
    ./users.nix
    ./testing.nix
  ];

  _module.args = {
    nur-no-packages = import inputs.nur {
      nurpkgs = pkgs;
    };
    myLib = self.lib pkgs.system;
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
      })

    ];
  };
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
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

  networking = {
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedTCPPortRanges = [ {from = 1714; to = 1764; } ];
      allowedUDPPorts = [ 22000 21027 ];
      allowedUDPPortRanges = [ {from = 1714; to = 1764; } ];
    };
  };

  systemd = {
    network.enable = true;
    services."netns@" = {
      description = "%I network namespace";
      before = ["network.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writers.writeDash "netns-up" ''
          ${pkgs.iproute}/bin/ip netns add $1
        ''} %I";
        ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
      };
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
      wireguard = {pkgs, file, ...}: ''
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
    };
    secrets = {
      flake-accessTokens = {
        rekeyFile = self + "/secrets/accessTokens.age";
        mode = "770";
        group = "nixbld";
      };
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
