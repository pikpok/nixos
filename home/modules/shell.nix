{
  lib,
  pkgs,
  ...
}:
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zsh = {
    enable = true;

    completionInit = ''
      autoload -Uz compinit
      if [[ -n ''${ZSH_COMPDUMP}(#qNmh-24) ]]; then
        compinit -C -d "''${ZSH_COMPDUMP}"
      else
        compinit -d "''${ZSH_COMPDUMP}"
      fi
    '';

    localVariables = {
      DEFAULT_USER = "$USER";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 545 ''
        typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
        typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
        typeset -g POWERLEVEL9K_MODE=powerline

        typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
          context
          dir
          vcs
        )
        typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
          status
          command_execution_time
          background_jobs
        )

        typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
        typeset -g POWERLEVEL9K_DIR_FOREGROUND=0
        typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=2
        typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3
        typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=3
        typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=1
        typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-aheadbehind)

        typeset -g POWERLEVEL9K_STATUS_OK=false
        typeset -g POWERLEVEL9K_STATUS_VERBOSE=false

      '')

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
        bindkey -e

        autoload -U up-line-or-beginning-search
        zle -N up-line-or-beginning-search

        autoload -U down-line-or-beginning-search
        zle -N down-line-or-beginning-search

        for keymap in emacs viins vicmd; do
          bindkey -M "$keymap" "^[[A" up-line-or-beginning-search
          bindkey -M "$keymap" "^[[B" down-line-or-beginning-search
          [[ -n "''${terminfo[kcuu1]}" ]] && bindkey -M "$keymap" "''${terminfo[kcuu1]}" up-line-or-beginning-search
          [[ -n "''${terminfo[kcud1]}" ]] && bindkey -M "$keymap" "''${terminfo[kcud1]}" down-line-or-beginning-search
        done

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

      (lib.mkOrder 1400 ''
        export FZF_CTRL_R_OPTS='--height=40% --layout=reverse'
        if [[ -t 1 ]]; then
          source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        fi
      '')

      (lib.mkOrder 1500 ''
        if [[ -t 1 ]]; then
          source ${pkgs.zsh-powerlevel10k}/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
        fi
      '')
    ];
  };
}
