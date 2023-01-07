{
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  nixpkgs.config.allowUnfree = true;

  home-manager.users.pikpok.home.stateVersion = "22.11";

  nix = {
    settings = {
      trusted-users = ["pikpok"];
      allowed-users = ["pikpok" "root"];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };

  environment.systemPackages = with pkgs; [
    vim
    helix
    wget
    git
    bat
    htop
  ];
}
