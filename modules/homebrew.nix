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
      "mobile-dev-inc/tap/maestro"
      "hashicorp/tap/terraform"
      "opencode"
      "awscli"
      "openjdk@17"
      "gh"
    ];

    casks = [
      "keepassxc"
      "firefox"
      "nextcloud"
      "steam"
      "calibre"
      "remarkable"
      "zoom"
      "android-studio"
      "betterdisplay"
      "beeper"
      "fx-cast-bridge"
      "utm"
      "raycast"
      "orbstack"
      "aldente"
      "spotify"
      "cursor"
      "bettermouse"
      "ghostty"
      "portfolioperformance"
      "chatgpt"
      "claude"
      "obsidian"
      "tailscale-app"
      "slack"
      "macwhisper"
      "postman"
      "tableplus"
      "whatsapp"
      "antigravity"
      "codex"
      "claude-code"
      "codex-app"
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
