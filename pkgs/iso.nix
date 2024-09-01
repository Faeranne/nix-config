{inputs, pkgs, lib}: let
  createZpool = lib.writers.writeBashBin {} ''
    root=$1
    sudo zpool create zroot $1
    sudo zfs create zroot/persist
    sudo zfs create zroot/nix
  '';

in inputs.nixos-generators.nixosGenerate {
  system = pkgs.system;
  modules = [
    (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
    ({pkgs, ...}:{
      nix = {
        registry = {
          nixpkgs.flake = inputs.nixpkgs;
        };
        settings = {
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
          createZpool
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
