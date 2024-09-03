{self, ...}:{
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
