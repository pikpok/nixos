{pkgs, ...}: {
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";

  home-manager.users.pikpok = {
    programs.zsh = {
      enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = ["git" "sudo"];
      };

      initExtra = ''
        . ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh
      '';
    };
  };
}
