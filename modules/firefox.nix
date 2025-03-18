{pkgs, ...}: {
  home-manager.users.pikpok.programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      settings = {
        "signon.rememberSignons" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "extensions.autoDisableScopes" = 0;
      };
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        keepassxc-browser
        vimium
        multi-account-containers
        react-devtools
        violentmonkey
        sponsorblock
        dearrow
        open-url-in-container
        # TODO: sticky-window-containers, fx_cast
      ];
    };
    policies = {
      CaptivePortal = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
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
