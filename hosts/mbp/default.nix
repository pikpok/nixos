{pkgs, ...}: {
  imports = [
    ../../modules/base-darwin.nix
    ../../modules/user.nix
    ../../modules/homebrew.nix
    ../../modules/shell.nix
    ./home.nix
  ];

  networking.hostName = "pikpok-mbp";

  environment.systemPackages = with pkgs; [
    asdf-vm
  ];

  ids.gids.nixbld = 350;
  system.stateVersion = 4; # Did you read the comment?
}
