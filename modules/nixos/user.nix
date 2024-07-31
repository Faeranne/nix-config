#This one is another doozy, but only because it does a *lot*.
#There will be more notes over time, but I'll get the basics together
#for now.
{config, inputs, systemConfig, lib, pkgs, flakeUtils, ...}: {

  #There's a few home-manager settings that work cross-user
  #these are set here.
  home-manager = {
    backupFileExtension = "bak";
    sharedModules = [ 
      #every user will import all the `homeManager` modules,
      #and rely on things like `elements` to enable
      #and disable them
      ../homeManager 
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    #We only define systemConfig as a special arg since we
    #can't define them per-user at this level
    extraSpecialArgs = {
      inherit systemConfig;
      inherit inputs;
    };
    #This will loop through each user and generate a set with
    #${username}=result set.  Note that each result
    #is a home-manager module.
    users = lib.genAttrs systemConfig.users (username: 
      {...}: let
        #We import the module here for use later in `imports`
        #because we can only define one module per user at this
        #level
        module = flakeUtils.getUserModule username;
      in { 
        _module.args = {
          #Here's where we actually get userConfig set.
          #this is because of how home-manager handles per-user
          #specialArgs.
          userConfig = flakeUtils.getUserConfig username;
        };
        imports = [
          #we could probably set the sharedModules here too.
          #but I might find a better way later, so I don't.
          module
        ];
      }
    );
  };

  #Since sudo capable users can manipulate the nix store
  #freely, setting them as trusted-users helps
  #cut down on some complexities with nixos-rebuild
  #from remote systems
  nix.settings.trusted-users = systemConfig.sudo;
  security.sudo.wheelNeedsPassword = true;

  #once again we're looping through the users to make
  #sets.
  users.users = lib.genAttrs systemConfig.users (name: let
    isSudo = builtins.elem name systemConfig.sudo;
    isGnome = (builtins.elem "gnome" systemConfig.elements);
    isKde = (builtins.elem "kde" systemConfig.elements);
    isSway = (builtins.elem "sway" systemConfig.elements);
    isGraphical = isGnome || isKde || isSway;
    isVirtualize = (builtins.elem "virtualization" systemConfig.elements);
    attrs = import ../../users/${name}/config.nix;
  in {
    isNormalUser = true;
    uid = attrs.uid;
    group = name;
    extraGroups = (
      ( if isSudo then [ "wheel" "docker" "tss" "adbusers" "dialout" ] else [] ) ++ 
      ( if isGraphical then [ "audio" ] else [] ) ++
      ( if (isSudo && isVirtualize) then [ "vboxusers" ] else [] )
    );
    description = attrs.name;
    hashedPasswordFile = config.age.secrets."user-${name}".path;
    openssh.authorizedKeys.keys = [] ++ attrs.authorizedKeys;
    shell = attrs.shell pkgs;
  });
  users.groups = lib.genAttrs systemConfig.users (name: let
    attrs = import ../../users/${name}/config.nix;
  in {
    gid = attrs.uid;
  });
  #this unwraps the user's hashed password into agenix.
  #while strictly redundant, hashs get broken anyways, and
  #an extra layer of difficulty should limit anyone
  #trying to break in from an otherwise public list.
  age.secrets = builtins.foldl' (input: name: let
    attrs = import ../../users/${name}/config.nix;
  in
    input // {
      "user-${name}".rekeyFile = attrs.passwordPath;
    }
  ) {} systemConfig.users;
  systemd.services = builtins.foldl' (input: name: let
    attrs = import ../../users/${name}/config.nix;
  in
    input // {
      "set${name}icon" = lib.mkIf (attrs ? avatar) {
        serviceConfig = {
          Type = "oneshot";
        };
        enable = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "accounts-daemon.service" ];
        before = [ "display-manager.service" ];
        requires = [ "accounts-daemon.service" ];
        script = ''
          cp ${attrs.avatar} /var/lib/AccountsService/icons/${name};
          echo "[User]
          Session=
          Icon=/var/lib/AccountsService/icons/${name}
          SystemAccount=false" > /var/lib/AccountsService/users/${name};
        '';
      };
    }
  ) {} systemConfig.users;
}
