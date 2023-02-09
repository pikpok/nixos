{
  pkgs,
  lib,
  home-manager,
  inputs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    "${inputs.nixos-m1}/apple-silicon-support"

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
    ../../modules/wireguard.nix
  ];

  sops.defaultSopsFile = ../../secrets/mbp-asahi.yaml;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
  };

  hardware.asahi.useExperimentalGPUDriver = true;

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
