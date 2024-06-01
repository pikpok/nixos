{
  imports = [
    ../../modules/base-linux.nix

    ../../modules/audio.nix
    ../../modules/avahi.nix
    ../../modules/user.nix
    ../../modules/shell.nix

    ./mpd.nix
    ./mosquitto.nix
    ./photoprism.nix
    ./backup.nix
    ./containers.nix
    ./samba.nix
  ];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = ["nofail" "noauto"];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/mnt/nas-ntfs" = {
      device = "/dev/disk/by-label/NASNTFS";
      options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100"];
    };
    "/mnt/nas" = {
      device = "/dev/disk/by-label/NAS";
      options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  networking = {
    hostName = "raspberrypi";

    interfaces.end0.ipv4.addresses = [
      {
        address = "192.168.100.8";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.100.1";
    nameservers = ["192.168.100.8" "1.1.1.1"];
    useDHCP = false;

    wireguard.interfaces = {
      wg0 = {
        ips = ["10.77.0.7/24"];
        privateKeyFile = "/root/wireguard-key";
        peers = [
          {
            publicKey = "zJc1neQD2vufvtJPkReaNXlElPQuuBjizW6wwu1pmnA=";
            allowedIPs = ["10.77.0.0/24"];
            endpoint = "c.pikpok.xyz:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usb_storage"
      "uas"
      "xhci-pci-renesas"
      "pcie-brcmstb"
      "reset-raspberrypi"
    ];

    kernelParams = ["console=ttyS0,115200n8" "console=tty0" "usb_storage.quirks=0bc2:3343:u,152d:0578:u"];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    supportedFilesystems = ["ntfs"];
  };

  hardware.enableRedistributableFirmware = true;

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
