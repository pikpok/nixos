{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  homebrew.enable = true;
  homebrew.cleanup = "zap";
  homebrew.autoUpdate = true;
  homebrew.global.brewfile = true;
  homebrew.global.noLock = true;

  homebrew.taps = [
    "homebrew/core"
    "homebrew/cask"
  ];

  homebrew.casks = [
    "keepassxc"
    "nextcloud"
    "tunnelblick"
    "spotify"
    "steam"
    "signal"
  ];
}
