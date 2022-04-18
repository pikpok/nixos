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
  ];

  networking.hostName = "pikpok-mbp";

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    obsidian
    asdf-vm
    go

    # Docker
    podman
    podman-compose
    qemu
  ];

  system.stateVersion = 4; # Did you read the comment?
}
