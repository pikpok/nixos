{pkgs, ...}: {
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";
  users.users.pikpok.shell = pkgs.zsh;
}
