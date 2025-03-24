{inputs, ...}: {
  imports = [
    inputs.koboldfactory.nixosModules.default
  ];
  virtualisation.oci-containers.containers = {
    "koboldfactory-minecraft" = {
      volumes = [
        "/persist/minecraft/koboldfactory:/data"
      ];
      environment = {
        EULA = "true";
        MAX_PLAYERS = "10";
        MOTD = "Kobold Factory Now Open - Apply within.";
        ENABLE_WHITELIST = "false";
        OPS = "c965d992-be3c-4431-8add-2c7562ad6551";
        SPAWN_PROTECTION = "0";
      };
      extraOptions = [
        "--ip=10.88.1.3"
      ];
    };
    "cozy-minecraft" = {
      autoStart = true;
      image = "itzg/minecraft-server:java17";
      volumes = [
        "/persist/minecraft/cozy1:/data"
      ];
      environment = {
        UID = "1000";
        EULA = "true";
        MEMORY = "4G";
        ENABLE_ROLLING_LOGS = "true";
        USE_AIKAR_FLAGS = "true";
        TYPE = "FORGE";
        VERSION = "1.18.2";
        FORGE_VERSION = "40.2.17";
        MAX_PLAYERS = "10";
        SNOOPER_ENABLE = "false";
        ALLOW_FLIGHT = "true";
        GUI = "false";
        MOTD = "Cozy Craft 2.0";
        ENABLE_WHITELIST = "true";
        ENFORCE_WHITELIST = "true";
        OPS = "faeranne";
        PACKWIZ_URL = "https://raw.githubusercontent.com/Faeranne/cozy-pack/master/pack.toml";
        SPAWN_PROTECTION = "0";
      };
      extraOptions = [
        "--ip=10.88.1.5"
      ];
    };
    router-minecraft = {
      autoStart = true;
      image = "itzg/mc-router";

      environment = {
        DEBUG = "True";
        MAPPING = "cozy.faeranne.com=10.88.1.5:25565";
      };

      ports = [
        "25565:25565"
      ];

      extraOptions = [
        "--ip=10.88.1.2"
      ];
    };
  };
}
