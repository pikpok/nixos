{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  programs.firefox.package = null;
  programs.zsh.initContent = lib.mkOrder 555 ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
