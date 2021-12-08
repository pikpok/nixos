{ pkgs, home-manager, lib, ... }:
let
  # fx_cast doesn't doesn't work on aarch64 yet
  includeFxCast = pkgs.system == "x86_64-linux";
in
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
      (lib.mkIf includeFxCast pkgs.nur.repos.ijohanne.firefoxPlugins.fx-cast)
    ];
  };

  environment.systemPackages = [
    (lib.mkIf includeFxCast pkgs.fx_cast_bridge)
  ];
}
