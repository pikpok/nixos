{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
    };

    global = {
      brewfile = true;
      lockfiles = true;
    };

    extraConfig = ''
      cask "firefox", args: { language: "pl-PL" }
    '';

    taps = [
      "homebrew/core"
      "homebrew/cask"
    ];

    casks = [
      "keepassxc"
      "firefox"
      "nextcloud"
      "tunnelblick"
      "spotify"
      "steam"
      "signal"
      "ngrok"
      "android-file-transfer"
      "calibre"
      "messenger"
      "remarkable"
      "zoom"
      "android-studio"
      "utm"
    ];

    masApps = {
      Xcode = 497799835;
      Wireguard = 1451685025;
      Broadcasts = 1469995354;
    };
  };

  home-manager.users.pikpok.programs.firefox.package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";
}
