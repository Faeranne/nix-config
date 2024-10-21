{config, self, pkgs, inputs, lib, ...}:{
  imports = [
    self.nixosModules.base
    self.nixosModules.proto
    self.nixosModules.extras.storage
    self.userModules.nina
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  security = {
    polkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkForce false;
    };
  };
  users.users.nina = {
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialHashedPassword = "$6$a85Gz9ZfsaqMElt9$3Z2d.KCAal.vJ6nhhZ.MUZ/jGGgMM/PSLamfzsTAlbs/sMJNk1RFKbkOeDWj5GpqgkFYuiXGVi0p79aLMPfgD0";
    hashedPasswordFile = lib.mkForce null;
  };

  services = {
    getty = {
      autologinUser = "nina";
    };
    openssh = {
      enable = true;
    };
  };
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
  };
  environment = {
    systemPackages = [
      self.packages.${pkgs.system}.wifi
    ] ++ (with pkgs; [
      git
      age
    ]);
  };
}
