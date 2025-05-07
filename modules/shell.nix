{pkgs, ...}: {
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";
  users.users.pikpok.shell = pkgs.zsh;

  home-manager.users.pikpok = {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.zsh = {
      enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = ["git" "sudo"];
      };

      localVariables = {
        DEFAULT_USER = "$USER";
      };

      initContent = ''
        . ${pkgs.asdf-vm}/etc/profile.d/asdf-prepare.sh

        flakify() {
          if [ ! -e flake.nix ]; then
            nix flake new -t github:nix-community/nix-direnv .
          elif [ ! -e .envrc ]; then
            echo "use flake" > .envrc
            direnv allow
          fi
          ''${EDITOR:-vim} flake.nix
        }
      '';
    };
  };
}
