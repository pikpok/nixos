{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    global = {
      brewfile = true;
    };

    extraConfig = ''
      cask "firefox", args: { language: "pl-PL" }
    '';

    taps = [
      "homebrew/services"
      {
        name = "btwld/fvm";
        trusted = true;
      }
      {
        name = "mobile-dev-inc/tap";
        trusted = true;
      }
      {
        name = "hashicorp/tap";
        trusted = true;
      }
      {
        name = "oven-sh/bun";
        trusted = true;
      }
      {
        name = "anomalyco/tap";
        trusted = true;
      }
      {
        name = "supabase/tap";
        trusted = true;
      }
      {
        name = "stablyai/orca";
        trusted = true;
      }
    ];

    brews = [
      "gnupg"
      "btwld/fvm/fvm"
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
      "anomalyco/tap/opencode-v2"
      "awscli"
      "openjdk@17"
      "gh"
      "fastlane"
      "go"
      "oven-sh/bun/bun"
      "poppler"
      "ruby"
      "tesseract"
      "uv"
      "rustup"
      "rtk"
      "supabase/tap/supabase"
    ];

    casks = [
      "cuadriver"
      "session-manager-plugin" # AWS SSM Session Manager plugin for awscli.
      "gcloud-cli"
      "hermes-desktop"
      "keepassxc"
      "firefox"
      "nextcloud"
      "steam"
      "calibre"
      "remarkable"
      "zoom"
      "android-studio"
      "betterdisplay"
      "signal"
      "fx-cast-bridge"
      "utm"
      "raycast"
      "orbstack"
      "stablyai/orca/orca"
      "aldente"
      "spotify"
      "cursor"
      "bettermouse"
      "ghostty"
      "portfolioperformance"
      "chatgpt" # Unified ChatGPT/Codex desktop app.
      "claude"
      "obsidian"
      "tailscale-app"
      "slack"
      "macwhisper"
      "postman"
      "tableplus"
      "whatsapp"
      "zed"
      "antigravity"
      "codex"
      "claude-code@latest"
      "home-assistant"
    ];

    masApps = {
      Xcode = 497799835;
      Wireguard = 1451685025;
      Cog = 1630499622;
    };
  };

  launchd.user.envVariables = {
    "OLLAMA_HOST" = "http://0.0.0.0:11434";
    # Keep the Apple-Silicon MLX path memory-efficient at agent-sized contexts.
    "OLLAMA_FLASH_ATTENTION" = "1";
    "OLLAMA_KV_CACHE_TYPE" = "q8_0";
  };
}
