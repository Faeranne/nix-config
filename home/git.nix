{...}:
{
  programs = {
    git = {
      enable = true;
      diff-so-fancy.enable = true;
      userEmail = "nina@projectmakeit.com";
      userName = "Nina Morgan";
      aliases = {
        lg = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all -n 15";
      };
    };
    git-cliff.enable = true;
    gitui.enable = true;
  };
}
