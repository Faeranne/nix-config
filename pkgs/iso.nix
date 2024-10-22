{self, inputs, pkgs, lib}: 
inputs.nixos-generators.nixosGenerate (let
  proto = self.nixosConfigurations.proto;
in {
  system = pkgs.system;
  modules = [
    (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
    ({pkgs, ...}:{
      isoImage = {
        includeSystemBuildDependencies = true;
        storeContents = [
          proto.config.system.build.toplevel
        ];
        splashImage = self + "/resources/labs-color-nix-snowflake.png";
      };
      nix = {
        registry = {
          nixpkgs.flake = inputs.nixpkgs;
        };
        settings = {
          substituters = [
            "https://nix-community.cachix.org"
            "https://cache.nixos.org"
            "https://ncache.faeranne.com"
          ];
          trusted-public-keys = [
            "ncache.faeranne.com:f0zP4VrDZbT9A/Xx3tfLD9M9sI9maSvFJg3zbGh7Ty0=%"
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
          self.packages.${pkgs.system}.wifi
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
})
