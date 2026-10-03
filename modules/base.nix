{
  pkgs,
  inputs,
  ...
}: {
  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = ["pikpok"];
      allowed-users = ["pikpok" "root"];
      nix-path = ["nixpkgs=${inputs.nixpkgs.outPath}"];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    bat
    htop
    jq
    httpie
    sops
  ];
}
