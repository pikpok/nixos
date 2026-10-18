{pkgs, ...}: let
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    keepassxc-browser
    libredirect
    vimium
    react-devtools
    violentmonkey
    sponsorblock
    dearrow
    simplifygmail
  ];
in {
  programs.firefox = {
    enable = true;
    configPath =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "Library/Application Support/Firefox"
      else ".mozilla/firefox";
    profiles.default = {
      id = 0;
      settings = {
        "signon.rememberSignons" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "extensions.autoDisableScopes" = 0;
      };
      extensions.packages = extensions;
    };
    policies = {
      CaptivePortal = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      # Firefox auto-updates replace the home-manager symlinks with regular
      # files, which then block activation; let Nix own these versions.
      ExtensionSettings = builtins.listToAttrs (map (p: {
          name = p.addonId;
          value.updates_disabled = true;
        })
        extensions);
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
    };
  };
}
