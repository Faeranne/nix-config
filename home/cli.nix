{pkgs, lib, inputs, ...}:
let
  impermanence = inputs.impermanence;
  fromGitHub = rev: user: repo: hash: pkgs.vimUtils.buildVimPluginFrom2Nix {
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
  home.packages = with pkgs; [
    silicon
  ];
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      diff-so-fancy.enable = true;
      userEmail = "nina@projecmtkaeit.com";
      userName = "Nina Morgan";
    };
    git-cliff.enable = true;
    gitui.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-fugitive
        tabular
        nerdtree
        vim-nerdtree-syntax-highlight
        nerdtree-git-plugin
        vim-markdown
        vim-airline
        vim-airline-themes
        vim-airline-clock
        vim-easymotion
        nerdcommenter
        vim-gitgutter
        vim-gnupg
        vim-javascript
        typescript-vim
        tsuquyomi
        vimproc-vim
        (fromGitHub "4a93122ae2139a12e2a56f064d086c05160b6835" "segeljakt" "vim-silicon" "sha256-8pCHtApD/xXav2UBVOVhkaHg3YS4aNCZ73mog04bYuA=")
      ];
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    autojump = {
      enable = true;
      enableZshIntegration = true;
    };
    broot = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "zsh-interactive-cd"
          "web-search"
          "wd"
          "vi-mode"
          "git"
          "python"
          "sudo"
          "systemd"
        ];
      };
    };
  };
}
