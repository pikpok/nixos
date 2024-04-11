{
  pkgs,
  lib,
  home-manager,
  inputs,
  ...
}: {
  imports = [
    ../../modules/base-darwin.nix
    ../../modules/firefox.nix
    ../../modules/user.nix
    ../../modules/vscode.nix
    ../../modules/homebrew.nix
    ../../modules/shell.nix
  ];

  networking.hostName = "pikpok-mbp";

  environment.systemPackages = with pkgs; [
    obsidian
    asdf-vm
  ];

  system.stateVersion = 4; # Did you read the comment?
}
