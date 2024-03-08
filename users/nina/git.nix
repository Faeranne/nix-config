{pkgs, ...}:
{
  programs = {
    git = {
      enable = true;
      userEmail = "nina@projectmakeit.com";
      userName = "Faer-Anne";
      aliases = {
        lg = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all -n 15";
      };
      difftastic = {
        enable = true;
        background = "dark";
        display = "side-by-side-show-both";
        color = "always";
      };
      extraConfig = {
        diff.algorithm = "histogram";
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        merge.conflictstyle = "zdiff3";
        push.default = "current";
        rebase.autostash = true;
        rerere.enabled = true;
        url."git@github.com:".pushInsteadOf = "https://github.com/";
      };
      ignores = [
        ".*.swp"
        "*~"
      ];
    };
    git-cliff.enable = true;
    gitui.enable = true;
  };
  home.packages = with pkgs; [
    gource
  ];
}
