{
  pkgs,
  home-manager,
  lib,
  ...
}: let
  # fx_cast doesn't doesn't work on aarch64 yet
  includeFxCast = pkgs.system == "x86_64-linux";
in
  lib.mkMerge [
    {
      home-manager.users.pikpok.programs.firefox = {
        enable = true;
        profiles.default = {
          id = 0;
          settings = {
            "signon.rememberSignons" = false;
          };
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

      environment.systemPackages = [
        (lib.mkIf includeFxCast pkgs.fx_cast_bridge)
      ];
    }

    # Firefox build doesn't work for Darwin, so install it from Homebrew
    (lib.mkIf pkgs.stdenv.isDarwin {
      home-manager.users.pikpok.programs.firefox.package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";

      homebrew = {
        extraConfig = ''
          cask "firefox", args: { language: "pl-PL" }
        '';

        casks = [
          "firefox"
        ];
      };
    })
  ]
