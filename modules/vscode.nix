{pkgs, ...}: {
  environment.systemPackages = with pkgs; [vscode];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [fira-code];
  };
}
