{pkgs, ...}: {
  environment.systemPackages = with pkgs; [vscode];
  fonts.fonts = with pkgs; [hack-font];
}
