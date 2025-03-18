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
      "openfortivpn"
      "gnupg"
      {
        name = "ollama";
        restart_service = "changed";
      }
      {
        name = "asimov";
        restart_service = "changed";
      }
    ];

    casks = [
      "keepassxc"
      "firefox"
      "nextcloud"
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
      "openmtp"
      "aldente"
      "tidal"
      "cursor"
      "bettermouse"
      "ghostty"
      "portfolioperformance"
      "cyberduck"
      "chatgpt"
      "claude"
      "obsidian"
    ];

    masApps = {
      Xcode = 497799835;
      Wireguard = 1451685025;
      Cog = 1630499622;
    };
  };

  home-manager.users.pikpok.programs.firefox.package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";
  home-manager.users.pikpok.programs.zsh.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
