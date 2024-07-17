{pkgs, lib, ...}:
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
  programs = {
    nixvim = {
      extraPlugins = with pkgs.vimPlugins; [
        vim-fugitive
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
            nixd.enable = true;
          };
        };
      };
      /*
      plugins = with pkgs.vimPlugins; [
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
      extraConfig = ''
        set nocompatible
        syntax on
        set encoding=utf-8
        set tabstop=2
        set shiftwidth=2
        set expandtab

        let g:silicon = {
        \ 'theme':  'gruvbox',
        \ 'font':   'Hack',
        \}
        
        autocmd StdinReadPre * let s:std_in=1
        autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
        autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
        let g:javascript_plugin_jsdoc = 1
        set cmdheight=2
        set updatetime=300
        set shortmess+=c
        
        set signcolumn=number
        
        autocmd BufNewFile,BufRead *.mts  set filetype=typescript
      '';
      */
    };
  };
}
