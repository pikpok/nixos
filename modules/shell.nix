{pkgs, ...}: {
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";
  users.users.pikpok.shell = pkgs.zsh;

  home-manager.users.pikpok = {
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

      initExtra = ''
        . ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh
      '';
    };
  };
}
