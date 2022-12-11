{
  pkgs,
  lib,
  home-manager,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    "${inputs.nixos-m1}/nix/m1-support"

    ../../modules/base-linux.nix

    ../../modules/audio.nix
    ../../modules/avahi.nix
    ../../modules/borg.nix
    ../../modules/docker.nix
    ../../modules/firefox.nix
    ../../modules/user.nix
    ../../modules/vscode.nix
    ../../modules/sway.nix
    ../../modules/shell.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot = {
      enable = true;
      # "error switching console mode" on boot.
      consoleMode = "auto";
      configurationLimit = 5;
    };
  };

  networking.hostName = "pikpok-mbp-asahi";
  networking.networkmanager.enable = true;

  # Temporarily override scaling for all displays here until I find better solution
  home-manager.users.pikpok.wayland.windowManager.sway.config.output."*".scale = "2";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}