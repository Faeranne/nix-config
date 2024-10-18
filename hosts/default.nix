inputs: let
  lib = inputs.nixpkgs.lib;
  specialArgs = {
      inherit (inputs.self) nixosModules;
      inherit (inputs) self;
      inherit inputs;
  };
  hosts = let
    folders = builtins.readDir ./.;
  in
    builtins.attrNames (lib.filterAttrs (name: type: type == "directory") folders);
  hostConfigs = lib.genAttrs hosts (host: lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./${host}
    ];
  });
  protoConfigs = lib.mapAttrs' (name: value: lib.nameValuePair ("proto_"+name) (lib.nixosSystem {
    specialArgs = {
      inherit (inputs.self) nixosModules;
      inherit (inputs) self;
      inherit inputs;
      sourceConfig = value.config;
    };
    modules = [
      inputs.self.nixosModules.base
      inputs.self.nixosModules.proto
      inputs.self.nixosModules.exras.storage
    ]; 
  })) hostConfigs;
in
  hostConfigs // protoConfigs
/*
in rec {
  sarah = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./sarah
    ];
  };
  hazel = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./hazel
    ];
  };
  greg = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ./greg
    ];
  };
} // forEachHost (hostCfg: inputs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  modules = [
    self.nixosModules.proto
  ];
});
*/
