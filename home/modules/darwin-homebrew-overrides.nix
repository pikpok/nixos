{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  programs.firefox.package = null;
  programs.zsh.profileExtra = ''
    source ~/.orbstack/shell/init.zsh 2>/dev/null || :
  '';
  programs.zsh.initContent = lib.mkOrder 555 ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
