{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix

    "${inputs.nixos-m1}/apple-silicon-support"

    ../../modules/base-linux.nix

    ../../modules/audio.nix
    ../../modules/avahi.nix
    ../../modules/borg.nix
    ../../modules/docker.nix
    ../../modules/user.nix
    ../../modules/vscode.nix
    ../../modules/shell.nix
    ../../modules/wireguard.nix
    ./home.nix
  ];

  sops.defaultSopsFile = ../../secrets/mbp-asahi/secrets.yaml;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
  };

  hardware.asahi.extractPeripheralFirmware = false;

  # TODO: Plymouth doesn't work?
  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;

  networking.hostName = "pikpok-mbp-asahi";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  services.getty.autologinUser = "pikpok";
  services.gvfs.enable = true;

  # Needed when HM user packages provide xdg-desktop-portal definitions.
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
