{
  pkgs,
  lib,
  ...
}: {
  networking = {
    useNetworkd = true;
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
          ${lib.getExe pkgs.iproute2} netns add $1
          ${lib.getExe pkgs.iproute2} netns exec $1 ${lib.getExe pkgs.iproute2} link set lo up
        ''} %I";
        ExecStop = "${lib.getExe pkgs.iproute2} netns del %I";
      };
    };
  };
}
