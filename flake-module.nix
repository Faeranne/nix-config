{ self, inputs, lib, config, ... }:
let

  inherit (builtins) pathExists readDir readFileType elemAt;
  inherit (lib) mkOption types optionals literalExpression mapAttrs concatMapAttrs genAttrs mkIf;
  inherit (lib.strings) hasSuffix removeSuffix;
  cfg = config.ezConfigs;

  readModules = dir:
    if pathExists "${dir}.nix" && readFileType "${dir}.nix" == "regular" then
      { default = dir; }
    else if pathExists dir && readFileType dir == "directory" then
      concatMapAttrs
        (entry: type:
          let
            dirDefault = "${dir}/${entry}/default.nix";
          in
          if type == "regular" && hasSuffix ".nix" entry then
            { ${removeSuffix ".nix" entry} = "${dir}/${entry}"; }
          else if pathExists dirDefault && readFileType dirDefault == "regular" then
            { ${entry} = dirDefault; }
          else { }
        )
        (readDir dir)
    else { }
  ;

  injectEarly = earlyArgs: modules:
    if earlyArgs == { }
    then modules
    else
      mapAttrs
        (_: path:
          let
            mod = import path;
          in
          if lib.isFunction mod
          then
            let
              modArgs = lib.functionArgs mod;
              subArgs = lib.filterAttrs (name: _: builtins.hasAttr name modArgs) earlyArgs;
              left = builtins.removeAttrs modArgs (builtins.attrNames subArgs);
              func = args: mod (args // subArgs);
            in
            lib.setFunctionArgs func left
          else path
        )
        modules;

  # This is a workaround the types.attrsOf (type.submodule ...) functionality.
  # We can't ensure that each host/ user present in the appropriate directory
  # is also present in the attrset, so we need to create a default module for it.
  # That way we can fallback to it if it's not present in the attrset.
  # Is there a better way to do this? Maybe defining a custom type?
  defaultSubmodule = submodule:
    concatMapAttrs
      (opt: optDef:
        if optDef ? default then
          { ${opt} = optDef.default; }
        else { }
      )
      submodule.options;

  configurationOptions = configType: {
    modulesDirectory = mkOption {
      default = if cfg.root != null then "${cfg.root}/${configType}-modules" else ./unset-directory;
      defaultText = literalExpression "\"\${ezConfigs.root}/${configType}-modules\"";
      type = types.path;
      description = ''
        The directory containing ${configType}Modules.
      '';
    };

    configurationsDirectory = mkOption {
      default = if cfg.root != null then "${cfg.root}/${configType}-configurations" else ./unset-directory;
      defaultText = literalExpression "\"\${ezConfigs.root}/${configType}-configurations\"";
      type = types.path;
      description = ''
        The directory containing ${configType}Configurations.
      '';
    };

    earlyModuleArgs = mkOption {
      default = cfg.earlyModuleArgs;
      defaultText = literalExpression "ezConfigs.earlyModuleArgs";
      type = types.attrsOf types.anything;
      description = ''
        Extra arguments to pass to all ${configType}Modules before exporting them.
      '';
    };

    extraSpecialArgs = mkOption {
      default = cfg.globalArgs;
      defaultText = literalExpression "ezConfigs.globalArgs";
      type = types.attrsOf types.anything;
      description = ''
        Extra arguments to pass to all homeConfigurations.
      '';
    };
  };

in
{
  options.ezConfigs = {
    topology = configurationOptions "topology";
  };

  config = {
    flake = {
      topologyModules = injectEarly cfg.topology.earlyModuleArgs (readModules cfg.topology.modulesDirectory);
    };
    perSystem = {...}: {
      topology.modules = [
        self.topologyModules.default
      ];
    };
  };
}
