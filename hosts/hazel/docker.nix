{...}:{
  virtualisation.oci-containers.containers = {
    "cozy-minecraft" = {
      autoStart = true;
      image = "itzg/minecraft-server:java17";
      volumes = [
        "/persist/minecraft/cozy1:/data"
      ];
      environment = {
        UID="1000";
        EULA="true";
        MEMORY="4G";
        ENABLE_ROLLING_LOGS="true";
        USE_AIKAR_FLAGS="true";
        TYPE="FORGE";
        VERSION="1.18.2";
        FORGE_VERSION="40.2.17";
        MAX_PLAYERS="10";
        SNOOPER_ENABLE = "false";
        ALLOW_FLIGHT="true";
        GUI="false";
        MOTD="Cozy Craft 2.0";
        ENABLE_WHITELIST="true";
        ENFORCE_WHITELIST="true";
        OPS="faeranne";
        PACKWIZ_URL="https://raw.githubusercontent.com/Faeranne/cozy-pack/master/pack.toml";
        SPAWN_PROTECTION="0";
      };
      extraOptions = [
        "--ip=10.88.1.5"
      ];
    };
    "gobbo-craft" = {
      autoStart = true;
      image = "itzg/minecraft-server:java17";
      volumes = [
        "/persist/minecraft/gobbo:/data"
      ];
      environment = {
        UID="1000";
        EULA="true";
        MEMORY="4G";
        ENABLE_ROLLING_LOGS="true";
        USE_AIKAR_FLAGS="true";
        TYPE="FORGE";
        VERSION="1.18.2";
        FORGE_VERSION="40.2.21";
        MAX_PLAYERS="4";
        SNOOPER_ENABLE = "false";
        ALLOW_FLIGHT="true";
        GUI="false";
        MOTD="Sleepover!";
        ENABLE_WHITELIST="true";
        ENFORCE_WHITELIST="true";
        OPS="faeranne";
        SPAWN_PROTECTION="0";
      };
      extraOptions = [
        "--ip=10.88.1.4"
      ];
    };
    "create-lab-minecraft" = {
      autoStart = true;
      image = "itzg/minecraft-server:java17";
      volumes = [
        "/persist/minecraft/create-lab:/data"
      ];
      ports = [
        "3876:3876"
        "24454:24454/udp"
      ];
      environment = {
        UID="1000";
        EULA="true";
        MEMORY="8G";
        ENABLE_ROLLING_LOGS="true";
        USE_AIKAR_FLAGS="true";
        TYPE="NEOFORGE";
        VERSION="1.20.1";
        NEOFORGE_VERSION="47.1.106";
        MAX_PLAYERS="10";
        SNOOPER_ENABLE = "false";
        ALLOW_FLIGHT="true";
        GUI="false";
        LEVEL_TYPE="large_biomes";
        ENABLE_COMMAND_BLOCK="true";
        MOTD="Create: Lab";
        ENABLE_WHITELIST="true";
        ENFORCE_WHITELIST="true";
        OPS="faeranne";
        PACKWIZ_URL="https://git.faeranne.com/faeranne/create-labs/raw/branch/main/src/pack.toml";
        SPAWN_PROTECTION="0";
      };
      extraOptions = [
        "--ip=10.88.1.3"
      ];
    };
    router-minecraft = {
      autoStart = true;
      image = "itzg/mc-router";

      environment = {
        DEBUG = "True";
        MAPPING = "createlab.faeranne.com=10.88.1.3:25565,gobbocraft.faeranne.com=10.88.1.4:25565,cozy.faeranne.com=10.88.1.5:25565";
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
