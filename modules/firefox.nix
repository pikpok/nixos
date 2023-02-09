{
  pkgs,
  home-manager,
  lib,
  ...
}: let
  # fx_cast doesn't doesn't work on aarch64 yet
  includeFxCast = pkgs.system == "x86_64-linux";
in {
  home-manager.users.pikpok.programs.firefox = {
    enable = true;
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
        # TODO: sticky-window-containers, ModHeader
        (lib.mkIf includeFxCast pkgs.nur.repos.ijohanne.firefoxPlugins.fx-cast)
      ];
    };
  };

  environment.systemPackages = [
    (lib.mkIf includeFxCast pkgs.fx_cast_bridge)
  ];
}
