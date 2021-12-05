{ pkgs, home-manager, ... }: {
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
    ];
  };
}
