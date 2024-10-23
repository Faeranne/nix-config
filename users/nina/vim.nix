{inputs, systemConfig, pkgs, lib, ...}:
let
  fromGitHub = rev: user: repo: hash: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = rev;
    src = pkgs.fetchFromGitHub {
      owner = user;
      repo = repo;
      rev = rev;
      hash = hash;
    };
  };
in
{
  home = {
    packages = with pkgs; [
      alejandra
      nixd
    ];
  };
  programs = {
    nixvim = {
      extraPlugins = with pkgs.vimPlugins; [
        vim-fugitive
        vim-airline-themes
        (
          fromGitHub 
          "4a93122ae2139a12e2a56f064d086c05160b6835"
          "segeljakt"
          "vim-silicon"
          "sha256-8pCHtApD/xXav2UBVOVhkaHg3YS4aNCZ73mog04bYuA="
        )
      ];
      plugins = {
        fugitive.enable = true;
        gitgutter = {
          enable = true;
        };
        airline = {
          enable = true;
        };
        nvim-tree = {
          enable = true;
          openOnSetup = true;
          openOnSetupFile = true;

        };
        nix = {
          enable = true;
        };
        git-conflict.enable = true;
        neocord.enable = true;
        lsp = {
          enable = true;
          servers = {
            nixd = {
              enable = true;
              settings = {
                formatting.command = [
                  "alejandra"
                ];
                options = {
                  nixos.expr = "(builtins.getFlake \"${inputs.self}.nixosConfigurations.${systemConfig.networking.hostName}.options";
                };
              };
            };
          };
        };
      };
    };
  };
}
