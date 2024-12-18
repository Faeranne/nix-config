{
  systemConfig,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  config = lib.mkIf systemConfig.xdg.portal.enable {
    home.packages = with inputs.ags.packages.${pkgs.system}; [
      io
      notifd
    ];

    programs.ags = {
      enable = false;

      configDir = ./ags;

      extraPackages = with pkgs; [
      ];
    };
  };
}
