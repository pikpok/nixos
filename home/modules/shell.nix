{
  lib,
  pkgs,
  ...
}: {
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

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        # Keep completion dumps under cache and make sure zsh core completions
        # are always available before compinit.
        ZSH_COMPDUMP="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump-''${HOST%%.*}-''${ZSH_VERSION}"
        mkdir -p "''${ZSH_COMPDUMP:h}"
        fpath=(
          ${pkgs.zsh}/share/zsh/$ZSH_VERSION/functions
          ${pkgs.zsh}/share/zsh/site-functions
          ${pkgs.zsh}/share/zsh/vendor-completions
          $fpath
        )
      '')

      (lib.mkOrder 1000 ''
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
      '')
    ];
  };
}
