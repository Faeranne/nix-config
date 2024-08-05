{ lib, systemConfig, ...}:{
  config = lib.mkIf (systemConfig.networking.hostName ==  "sarah") {
    wayland.windowManager.sway.config = {
      assigns = {
        "4" = [
          {app_id = "vesktop";}
        ];
      };
    };
  };
}
