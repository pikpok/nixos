{
  pkgs,
  lib,
  ...
}: {
  home-manager.users.pikpok.programs.firefox =
    {
      enable = true;
      profiles.default = {
        id = 0;
        settings = {
          "signon.rememberSignons" = false;
          "media.ffmpeg.vaapi.enabled" = true;
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
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
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
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
    };
}
