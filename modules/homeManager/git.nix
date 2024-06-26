{pkgs, lib, userConfig, systemConfig, ...}: let
  isDesktop = (builtins.elem "desktop" systemConfig.elements);
  isLaptop = (builtins.elem "laptop" systemConfig.elements);
in
{
  programs = {
    git = {
      enable = true;
      aliases = lib.mkDefault {
        lg = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      };
      difftastic = lib.mkDefault {
        enable = true;
        background = "dark";
        display = "side-by-side-show-both";
        color = "always";
      };
      extraConfig = lib.mkDefault {
        diff.algorithm = "histogram";
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        merge.conflictstyle = "zdiff3";
        push.default = "current";
        rebase.autostash = true;
        rerere.enabled = true;
        url."git@github.com:".pushInsteadOf = "https://github.com/";
      };
      ignores = lib.mkDefault [
        ".*.swp"
        "*~"
      ];
    };
    git-cliff.enable = true;
    gitui.enable = true;
    ssh = {
      enable = true;
      matchBlocks = lib.mkIf (isDesktop || isLaptop) {
        "github.com" = {
          user = "git";
        };
      };
    };
  };
}
