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
      upgrade = true;
    };

    global = {
      brewfile = true;
      lockfiles = false;
    };

    extraConfig = ''
      cask "firefox", args: { language: "pl-PL" }
    '';

    taps = [
      "homebrew/services"
    ];

    brews = [
      {
        name = "ollama";
        restart_service = "changed";
      }
    ];

    casks = [
      "keepassxc"
      "firefox"
      "nextcloud"
      "spotify"
      "steam"
      "ngrok"
      "calibre"
      "remarkable"
      "zoom"
      "android-studio"
      "betterdisplay"
      "beeper"
      "fx-cast-bridge"
      "utm"
      "raycast"
      "iterm2"
      "orbstack"
      "notion"
      "screen-studio"
      "openmtp"
      "aldente"
      "tidal"
      "cursor"
    ];

    masApps = {
      Xcode = 497799835;
      Wireguard = 1451685025;
      Capcut = 1500855883;
      Cog = 1630499622;
    };
  };

  home-manager.users.pikpok.programs.firefox.package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";
}
