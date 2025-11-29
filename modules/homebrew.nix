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
      "leoafarias/fvm"
      "mobile-dev-inc/tap"
      "hashicorp/tap"
    ];

    brews = [
      "openfortivpn"
      "gnupg"
      "fvm"
      "cocoapods"
      "ansible"
      {
        name = "ollama";
        restart_service = "changed";
      }
      {
        name = "asimov";
        restart_service = "changed";
      }
      "maestro"
      "hashicorp/tap/terraform"
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
      "spotify"
      "cursor"
      "bettermouse"
      "ghostty"
      "portfolioperformance"
      "cyberduck"
      "chatgpt"
      "claude"
      "obsidian"
      "tailscale-app"
      "slack"
      "macwhisper"
      "postman"
      "todoist-app"
      "tableplus"
      "whatsapp"
    ];

    masApps = {
      Xcode = 497799835;
      Wireguard = 1451685025;
      Cog = 1630499622;
    };
  };

  launchd.user.envVariables = {
    "OLLAMA_HOST" = "http://0.0.0.0:11434";
  };

  home-manager.users.pikpok.programs.firefox.package = null;
  home-manager.users.pikpok.programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
