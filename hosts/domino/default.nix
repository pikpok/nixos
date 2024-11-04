{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/base-linux.nix
    ../../modules/user.nix
    ../../modules/shell.nix
    ../../modules/avahi.nix
    ./mpd.nix
    ./mosquitto.nix
    ./containers.nix
    ./samba.nix
    ./photoprism.nix
    ./immich.nix
    ./traefik.nix
    ./wireguard.nix
    ./backup.nix
    ./uptime-kuma.nix
    ./intel-gpu.nix
    ./grafana.nix
    ./actual.nix
    ./n8n.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "24.11";
}
