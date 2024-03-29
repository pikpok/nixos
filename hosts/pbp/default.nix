{ pkgs, lib, home-manager, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-linux.nix

    ../../modules/audio.nix
    ../../modules/avahi.nix
    ../../modules/borg.nix
    ../../modules/docker.nix
    ../../modules/firefox.nix
    ../../modules/hyprland.nix
    ../../modules/user.nix
    ../../modules/vscode.nix
    ../../modules/shell.nix
  ];

  boot = {
    # we use Tow-Boot now:
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    loader.generic-extlinux-compatible.configurationLimit = 3;

    tmpOnTmpfs = false;
    cleanTmpDir = true;

    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    kernelParams = [
      "mitigations=off"
      "console=ttyS2,1500000n8"
      "console=tty0"
    ];
  };

  console.earlySetup = true; # luks
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  networking.hostName = "pikpok-pbp";
  networking.networkmanager.enable = true;

  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
