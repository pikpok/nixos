{pkgs, ...}: {
  environment.systemPackages = with pkgs; [vscode];
  fonts.packages = with pkgs; [fira-code];
}
