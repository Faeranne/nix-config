{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) str bool;
  cfg = config.nexos.networking;
  enable = config.nexos.enable;
  configFile = if config.nexos.info.configPath != null then builtins.fromJSON (builtins.readFile config.nexos.info.configPath) else null;
in {

  options = {
    nexos = {
      networking = {
        online = mkOption {
          type = bool;
          default = true;
          description = "System generally has an internet connection when on.";
        };
        wireguard = {
          enable = mkEnableOption "Enable underlying wireguard system";
        };
        upstream = {
          enable = mkEnableOption "Enable upstream port";
          mac = mkOption {
            description = "Hardware MAC address of the default upstream port.";
            type = str;
          };
        };
      };
    };
  };

  config = mkIf enable {
    nexos.networking = {
      upstream.mac = mkIf (configFile != null) configFile.mac;
    };
    age = {
      generators = {
        # unused right now, but makes 3 additional files for use
        # with yggdrasil.
        # secret.ip - the final ipv6 address that this secret shows up as
        # secret.pub - the public key of this secret
        # secret.net - the subnet address that this secret responds to
        yggdrasilKeyConf = {
          pkgs,
          file,
          ...
        }: ''
          pkey=$(${pkgs.openssl}/bin/openssl genpkey -algorithm ed25519 -outform pem | ${pkgs.openssl}/bin/openssl pkey -inform pem -text -noout)
          priv=$(echo "$pkey" | sed '3,5p;d' | tr -d "\n :")
          pub=$(echo "$pkey" | sed '7,10p;d' | tr -d "\n :")
          privConf="{\"PrivateKey\":\"$priv$pub\"}"
          ${pkgs.yggdrasil}/bin/yggdrasil -useconf -address <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".ip")}
          ${pkgs.yggdrasil}/bin/yggdrasil -useconf -publickey <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
          ${pkgs.yggdrasil}/bin/yggdrasil -useconf -subnet <<< "$privConf" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".net")}
          echo "$privConf"
        '';
        # Creates a wireguard private and public key pair.
        # secret.age - encrypted private key for this secret.
        # secret.pub - plaintext public key for this secret. used in wireguard peer configs
        wireguard = {
          pkgs,
          file,
          ...
        }: ''
          priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
          ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
          echo "$priv"
        '';
      };
      secrets = {
        wggateway = {
          group = "systemd-network";
          mode = "770";
          generator = {
            script = "wireguard";
            tags = [ "wireguard" ];
          };
        };
        wghub = {
          group = "systemd-network";
          mode = "770";
          generator = {
            script = "wireguard";
            tags = [ "wireguard" ];
          };
        };
      };
    };
    systemd = {
      network = {
        enable = true;
        links = {
          "upstream" = mkIf cfg.upstream.enable {
            config = true;
            matchConfig = {
              PermanentMACAddress = cfg.upstream.mac;
            };
            linkConfig = {
              Name = "upstream";
            };
          };
        };
      };
    };

    networking = {
      useNetworkd = true;
      nat = {
        externalInterface = mkIf cfg.upstream.enable "upstream";
        enable = true;
        internalInterfaces = mkIf cfg.wireguard.enable [
          "wggateway"
        ];
      };
      wireguard.interfaces = mkIf cfg.wireguard.enable {
        "wggateway" = {
          privateKeyFile = config.age.secrets.wggateway.path;
          listenPort = 51820;
          socketNamespace = "container";
          interfaceNamespace = "init";
        };
        "wghub" = {
          privateKeyFile = config.age.secrets.wghub.path;
          listenPort = 51820;
          socketNamespace = "init";
          interfaceNamespace = "container";
        };
      };
    };
  };
}
