{ pkgs, ... }:
{
  # Select internationalisation properties.
  i18n.defaultLocale = "pl_PL.UTF-8";
  console = { keyMap = "pl"; };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  nixpkgs.config.allowUnfree = true;

  services.timesyncd.enable = true;

  services.upower.enable = true;

  services.openssh.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    settings = {
      trusted-users = [ "pikpok" ];
      allowed-users = [ "pikpok" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    bat
  ];
}
