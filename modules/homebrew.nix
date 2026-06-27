{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  homebrew = {
    enable = true;

    onActivation = {
      # Homebrew 6 renamed `brew bundle --cleanup` to `--force-cleanup`, but
      # nix-darwin still emits the old flag for cleanup = "zap"/"uninstall",
      # so pass the new flags manually until nix-darwin#1789 lands.
      cleanup = "none";
      extraFlags = [
        "--zap"
        "--force-cleanup"
      ];
      autoUpdate = true;
      upgrade = true;
    };

    global = {
      brewfile = true;
    };

    # Homebrew 6 requires non-official taps to be explicitly trusted.
    # nix-darwin's `taps` option can't express `trusted: true` yet
    # (nix-darwin#1789), so declare those taps as raw Brewfile lines here;
    # `brew bundle` applies trust before installing, regardless of file order.
    extraConfig = ''
      cask "firefox", args: { language: "pl-PL" }
      tap "leoafarias/fvm", trusted: true
      tap "mobile-dev-inc/tap", trusted: true
      tap "hashicorp/tap", trusted: true
      tap "oven-sh/bun", trusted: true
      tap "anomalyco/tap", trusted: true
    '';

    taps = [
      "homebrew/services"
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
      "anomalyco/tap/opencode"
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
      "signal"
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
      "zed"
      "antigravity"
      "codex"
      "claude-code@latest"
      "codex-app"
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
  };
}
