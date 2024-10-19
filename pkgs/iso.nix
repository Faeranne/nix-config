{self, inputs, pkgs, lib}: 
inputs.nixos-generators.nixosGenerate {
  system = pkgs.system;
  modules = [
    (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
    ({pkgs, ...}:{
      nix = {
        registry = {
          nixpkgs.flake = inputs.nixpkgs;
        };
        settings = {
          substituters = [
            "https://ncache.faeranne.com"
            "https://nix-community.cachix.org"
            "https://cache.nixos.org"
          ];
          trusted-public-keys = [
            "ncache.faeranne.com:W9hbuDECHbOiywk+TiqPMdkRG2mW8EasNbcDP8BFVCw="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          experimental-features = [ "nix-command" "flakes" "ca-derivations"];
        };
      };
      zramSwap = {
        enable = true;
      };
      systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
      environment = {
        etc = {
          "ageKey".text = "age1yubikey1qtfy343ld8e5sxlvfufa4hh22pm33f6sjq2usx6mmydrmu7txzu7g5xm9vr";
        };
        systemPackages = [
          self.packages.${pkgs.system}.installSystem
          self.packages.${pkgs.system}.finishInstall
        ] ++ (with pkgs; [
          git
          age
        ]);
      };
      users.users.root.openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMg89gg80Z24JNaj1qeuEk4zxfA2AabKcuo6JHjSHu3xAAAAC3NzaDpwcml2YXRl nina@desktop"
      ];
    })
  ];
  format = "install-iso";
}
