{
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  nixpkgs.config.allowUnfree = true;

  home-manager.users.pikpok.home.stateVersion = "18.09";

  nix = {
    package = pkgs.nixFlakes;
    trustedUsers = ["pikpok"];
    allowedUsers = ["pikpok" "root"];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    bat
  ];
}
